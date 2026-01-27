import 'dart:developer';
import 'package:chiroku_cafe/brick/models/user.model.dart';
import 'package:chiroku_cafe/brick/repositories/repositories.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'connectivity_service.dart';
import 'avatar_cache_service.dart';

class OfflineUserService extends GetxService {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final AvatarCacheService _avatarCache = Get.find<AvatarCacheService>();

  final RxBool isSyncing = false.obs;
  final RxList<User> users = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();

    // Listen to connectivity changes
    ever(_connectivityService.isOnline, (isOnline) {
      if (isOnline) {
        syncWithRemote();
      }
    });
  }

  // Load users (offline-first)
  Future<void> loadUsers() async {
    try {
      log('🔄 Loading users...');

      // If online, fetch from Supabase first to ensure fresh data
      if (_connectivityService.isConnected) {
        log('📡 Device online, fetching from Supabase...');
        try {
          await _fetchFromSupabase();
        } catch (e) {
          log('⚠️ Failed to fetch from Supabase: $e');
          log('⚠️ Stack trace: ${StackTrace.current}');
        }
      } else {
        log('📴 Device offline, loading from local database...');
      }

      // Get from local Brick repository
      final loadedUsers = await Repository().get<User>();
      users.value = loadedUsers;
      log('✅ Loaded ${loadedUsers.length} users from local database');

      if (loadedUsers.isNotEmpty) {
        log(
          '📋 First user: ${loadedUsers.first.fullName} (${loadedUsers.first.email})',
        );
      }

      // Cache avatars
      for (var user in users) {
        if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
          await _avatarCache.downloadAndCacheAvatar(user.avatarUrl!, user.id);
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error loading users: $e');
      log('❌ Stack trace: $stackTrace');
    }
  }

  // Fetch from Supabase and save to local database
  Future<void> _fetchFromSupabase() async {
    try {
      log('📥 Fetching users from Supabase...');

      // Get Supabase client
      final supabase = Supabase.instance.client;

      log('🔍 Supabase client initialized');

      // Fetch all users from Supabase
      final response = await supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      log('📦 Received ${response.length} users from Supabase');

      if (response.isEmpty) {
        log('⚠️ No users found in Supabase table "users"');
        return;
      }

      // Log first user data for debugging
      log('🔍 First user data: ${response.first}');

      // Convert to User models and save to local database
      for (var userData in response) {
        try {
          final user = User(
            id: userData['id'] as String,
            fullName: userData['full_name'] as String,
            email: userData['email'] as String?,
            avatarUrl: userData['avatar_url'] as String?,
            role: userData['role'] as String,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'] as String)
                : null,
            updatedAt: userData['updated_at'] != null
                ? DateTime.parse(userData['updated_at'] as String)
                : null,
          );

          // Save to local database
          await Repository().upsert<User>(user);
          log('✅ Saved user: ${user.fullName}');
        } catch (e) {
          log('❌ Error saving user: $e');
          log('❌ User data: $userData');
        }
      }

      log('✅ Synced ${response.length} users to local database');
    } catch (e, stackTrace) {
      log('❌ Error fetching from Supabase: $e');
      log('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Add user (works offline)
  Future<void> addUser({
    required String fullName,
    String? email,
    String? avatarUrl,
    required String role,
  }) async {
    try {
      final user = User(
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Repository().upsert<User>(user);

      // Add to local list immediately
      users.add(user);

      log('✅ User added: $fullName');
    } catch (e) {
      log('❌ Error adding user: $e');
      rethrow;
    }
  }

  // Update user (works offline)
  Future<void> updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await Repository().upsert<User>(updatedUser);

      // Update local list
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }

      log('✅ User updated: ${user.fullName}');
    } catch (e) {
      log('❌ Error updating user: $e');
      rethrow;
    }
  }

  // Delete user (works offline)
  Future<void> deleteUser(User user) async {
    try {
      await Repository().delete<User>(user);

      // Remove from local list
      users.removeWhere((u) => u.id == user.id);

      log('✅ User deleted: ${user.fullName}');
    } catch (e) {
      log('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // Sync with remote
  Future<void> syncWithRemote() async {
    if (isSyncing.value || !_connectivityService.isConnected) return;

    try {
      isSyncing.value = true;
      log('🔄 Starting sync...');

      // Fetch from Supabase and save to local
      await _fetchFromSupabase();

      // Reload local data
      final loadedUsers = await Repository().get<User>();
      users.value = loadedUsers;

      // Process pending avatar uploads
      await _avatarCache.processPendingUploads();

      log('✅ Sync completed');
    } catch (e) {
      log('❌ Sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  // Get user by ID
  User? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  // Subscribe to users stream
  Stream<List<User>> subscribeToUsers() {
    return Repository().subscribe<User>().map((users) {
      this.users.value = users;
      return users;
    });
  }
}
