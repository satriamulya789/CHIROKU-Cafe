import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/services/admin_edit_user_service.dart';
import 'package:chiroku_cafe/shared/constants/protected_users.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/functions/image_cache_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class AdminEditUserController extends GetxController {
  final UserService _service = UserService();
  final snackbar = CustomSnackbar();
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());

  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final isOnline = true.obs;

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final roleController = TextEditingController(text: 'cashier');

  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _initUsersStream(); // ✅ Subscribe to users stream
    _listenToConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _usersSubscription?.cancel();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    roleController.dispose();
    isPasswordObscured.close();
    isConfirmPasswordObscured.close();
    super.onClose();
  }

  // ==================== CONNECTIVITY ====================
  Future<void> _initConnectivity() async {
    isOnline.value = await _networkInfo.isConnected;
    log('🌐 Initial connectivity: ${isOnline.value ? "Online" : "Offline"}');
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      log('🔄 Connectivity changed: ${connected ? "Online" : "Offline"}');
      isOnline.value = connected;

      if (connected) {
        snackbar.showSuccessSnackbar('Back online! Syncing data...');
        _syncWhenOnline();
      } else {
        snackbar.showInfoSnackbar(
          'You are offline. Changes will sync when online.',
        );
      }
    });
  }

  Future<void> _syncWhenOnline() async {
    try {
      await _service.syncPendingChanges();
      // Stream will auto-update UI, no need to manually fetch
      log('✅ Auto-sync completed');
    } catch (e) {
      log('❌ Auto-sync failed: $e');
    }
  }

  // ==================== INIT USERS STREAM ====================
  void _initUsersStream() {
    try {
      log('👁️ Controller: Setting up users stream...');
      _usersSubscription = _service.watchUsers().listen(
        (usersList) async {
          log('📥 Controller: Received ${usersList.length} users from stream');
          users.value = usersList;

          // Precache avatars in background
          await _precacheAvatarsInBackground(usersList);
        },
        onError: (error) {
          log('❌ Controller: Users stream error: $error');
          snackbar.showErrorSnackbar('Error loading users: $error');
        },
      );
      log('✅ Controller: Users stream initialized');
    } catch (e) {
      log('❌ Controller: Error initializing users stream: $e');
      snackbar.showErrorSnackbar('Failed to initialize users stream: $e');
    }
  }

  // ==================== PRECACHE AVATARS ====================
  Future<void> _precacheAvatarsInBackground(List<UserModel> usersList) async {
    try {
      final context = Get.context;
      if (context == null) {
        log('⚠️ Context not available for precaching');
        return;
      }

      final avatarUrls = usersList
          .where((u) => u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
          .map((u) => u.avatarUrl!)
          .toList();

      if (avatarUrls.isEmpty) {
        log('ℹ️ No avatars to precache');
        return;
      }

      log('🖼️ Starting precache for ${avatarUrls.length} avatars...');

      // Check which images are already cached
      int alreadyCached = 0;
      int needsDownload = 0;

      for (final url in avatarUrls) {
        final isCached = await ImageCacheHelper.isImageCached(url);
        if (isCached) {
          alreadyCached++;
        } else {
          needsDownload++;
        }
      }

      log(
        '📊 Cache status: $alreadyCached already cached, $needsDownload needs download',
      );

      // Precache only uncached images
      if (needsDownload > 0) {
        await ImageCacheHelper.precacheAvatars(context, avatarUrls);
        log('✅ Precaching completed');
      } else {
        log('✅ All avatars already cached');
      }
    } catch (e) {
      log('❌ Error precaching avatars: $e');
      // Don't show error to user, this is background operation
    }
  }

  List<UserModel> get filteredUsers {
    if (searchQuery.value.isEmpty) return users;
    return users.where((user) {
      return user.fullName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          (user.email?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  // ==================== FETCH USERS ====================
  Future<void> fetchUsers({
    bool showLoading = true,
    bool withPrecache = true,
  }) async {
    try {
      if (showLoading) isLoading.value = true;

      log('📥 Controller: Fetching users...');
      final usersList = await _service.fetchUsers();
      users.value = usersList;
      log('✅ Controller: Loaded ${users.length} users');

      // Precache avatars if requested
      if (withPrecache) {
        await _precacheAvatarsInBackground(usersList);
      }
    } catch (e) {
      log('❌ Controller: Error fetching users: $e');
      snackbar.showErrorSnackbar('Failed to fetch users: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  // ==================== CREATE USER ====================
  Future<void> createUser() async {
    try {
      if (!_validateCreateForm()) return;

      isLoading.value = true;
      log('➕ Controller: Creating user...');

      final userId = await _service.createUser(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        role: roleController.text,
      );

      await fetchUsers(showLoading: false);
      clearForm();
      Get.back();

      final message = isOnline.value
          ? 'User created successfully'
          : 'User created locally (ID: $userId). Will sync when online.';
      snackbar.showSuccessSnackbar(message);
      log('✅ Controller: User created with ID: $userId');
    } catch (e) {
      log('❌ Controller: Error creating user: $e');
      snackbar.showErrorSnackbar('Failed to create user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPDATE USER ====================
  Future<void> updateUser(UserModel user) async {
    try {
      if (ProtectedUsers.isProtected(user.email)) {
        snackbar.showErrorSnackbar(
          'This is a protected account and cannot be modified.',
        );
        return;
      }

      if (!_validateUpdateForm()) return;

      isLoading.value = true;
      log('✏️ Controller: Updating user ${user.id}...');

      await _service.updateUser(
        user.id,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        role: roleController.text,
      );

      // Stream will auto-update UI
      clearForm();
      Get.back();

      final message = isOnline.value
          ? 'User updated successfully'
          : 'User updated locally. Will sync when online.';
      snackbar.showSuccessSnackbar(message);
      log('✅ Controller: User updated');
    } catch (e) {
      log('❌ Controller: Error updating user: $e');
      snackbar.showErrorSnackbar('Failed to update user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE USER ====================
  Future<void> deleteUser(UserModel user) async {
    try {
      if (ProtectedUsers.isProtected(user.email)) {
        snackbar.showErrorSnackbar(
          'This is a protected account and cannot be deleted.',
        );
        return;
      }

      isLoading.value = true;
      log('🗑️ Controller: Deleting user ${user.id}...');

      await _service.deleteUser(user.id);
      // Stream will auto-update UI

      final message = isOnline.value
          ? 'User deleted successfully'
          : 'User deleted locally. Will sync when online.';
      snackbar.showSuccessSnackbar(message);
      log('✅ Controller: User deleted');
    } catch (e) {
      log('❌ Controller: Error deleting user: $e');
      final errorMessage = e.toString();
      if (errorMessage.contains('23503')) {
        _showCannotDeleteUserDialog();
      } else {
        snackbar.showErrorSnackbar('Failed to delete user: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showCannotDeleteUserDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cannot Delete User', style: AppTypography.h5),
        content: Text(
          'This user has associated records in the system (such as orders or reports) and cannot be deleted to preserve data integrity.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
            ),
            child: Text(
              'Understood',
              style: AppTypography.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FORM HELPERS ====================
  void setEditUser(UserModel user) {
    fullNameController.text = user.fullName;
    emailController.text = user.email ?? '';
    roleController.text = user.role;
    passwordController.clear();
    confirmPasswordController.clear();
  }

  bool _validateCreateForm() {
    if (fullNameController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Full name is required');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Email is required');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      snackbar.showErrorSnackbar('Please enter a valid email');
      return false;
    }
    if (passwordController.text.isEmpty) {
      snackbar.showErrorSnackbar('Password is required');
      return false;
    }
    if (passwordController.text.length < 6) {
      snackbar.showErrorSnackbar('Password must be at least 6 characters');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      snackbar.showErrorSnackbar('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateUpdateForm() {
    if (fullNameController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Full name is required');
      return false;
    }
    if (emailController.text.trim().isNotEmpty &&
        !GetUtils.isEmail(emailController.text.trim())) {
      snackbar.showErrorSnackbar('Please enter a valid email');
      return false;
    }
    return true;
  }

  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordObscured.value = true;
    isConfirmPasswordObscured.value = true;
    roleController.text = 'cashier';
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // ==================== MANUAL SYNC ====================
  Future<void> manualSync() async {
    if (!isOnline.value) {
      snackbar.showErrorSnackbar('Cannot sync while offline');
      return;
    }

    try {
      isLoading.value = true;
      snackbar.showInfoSnackbar('Syncing data...');
      log('🔄 Controller: Manual sync started...');

      await _service.manualSync();
      // Stream will auto-update UI

      snackbar.showSuccessSnackbar('Data synced successfully');
      log('✅ Controller: Manual sync completed');
    } catch (e) {
      log('❌ Controller: Manual sync failed: $e');
      snackbar.showErrorSnackbar('Sync failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SEARCH ====================
  Future<void> searchUsers(String query) async {
    try {
      updateSearchQuery(query);

      if (query.isEmpty) {
        return; // filteredUsers getter will show all
      }

      log('🔍 Searching for: $query');
      final results = await _service.searchUsers(query);
      log('📊 Found ${results.length} results');
    } catch (e) {
      log('❌ Search error: $e');
    }
  }

  // ==================== GET USERS BY ROLE ====================
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      return await _service.getUsersByRole(role);
    } catch (e) {
      log('❌ Error getting users by role: $e');
      return [];
    }
  }

  // ==================== GET USERS COUNT ====================
  Future<int> getUsersCount() async {
    try {
      return await _service.getUsersCount();
    } catch (e) {
      log('❌ Error getting users count: $e');
      return 0;
    }
  }

  // ==================== CLEAR IMAGE CACHE ====================
  Future<void> clearImageCache() async {
    try {
      isLoading.value = true;
      log('🗑️ Clearing image cache...');

      final cacheInfo = await ImageCacheHelper.getCacheInfo();
      log('📦 Cache info before clear: $cacheInfo');

      await ImageCacheHelper.clearCache();
      snackbar.showSuccessSnackbar('Image cache cleared successfully');
      log('✅ Image cache cleared');

      // Refresh users to re-download images
      await fetchUsers(showLoading: false, withPrecache: true);
    } catch (e) {
      log('❌ Error clearing image cache: $e');
      snackbar.showErrorSnackbar('Failed to clear cache: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== CHECK CACHE STATUS ====================
  Future<void> checkCacheStatus() async {
    try {
      final cacheInfo = await ImageCacheHelper.getCacheInfo();
      log('📦 Current cache info: $cacheInfo');

      int cachedCount = 0;
      for (final user in users) {
        if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
          final isCached = await ImageCacheHelper.isImageCached(
            user.avatarUrl!,
          );
          if (isCached) cachedCount++;
        }
      }

      log('📊 $cachedCount of ${users.length} avatars are cached');
      snackbar.showInfoSnackbar('$cachedCount avatars cached locally');
    } catch (e) {
      log('❌ Error checking cache status: $e');
    }
  }
}
