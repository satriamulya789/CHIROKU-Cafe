import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/services/admin_edit_user_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditUserController extends GetxController {
  final UserService _service = UserService();
  final snackbar = CustomSnackbar();

  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

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
    fetchUsers();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    isPasswordObscured.close();
    isConfirmPasswordObscured.close();
    roleController.dispose();
    super.onClose();
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

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _service.fetchUsers();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setEditUser(UserModel user) {
    fullNameController.text = user.fullName;
    emailController.text = user.email ?? '';
    roleController.text = user.role;
    passwordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> createUser() async {
    try {
      if (!_validateCreateForm()) return;

      isLoading.value = true;
      await _service.createUser(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        role: roleController.text,
      );
      await fetchUsers();
      clearForm();
      Get.back();
      snackbar.showSuccessSnackbar('User created successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to create user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String id) async {
    try {
      if (!_validateUpdateForm()) return;

      isLoading.value = true;
      await _service.updateUser(
        id,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        role: roleController.text,
      );
      await fetchUsers();
      clearForm();
      Get.back();
      snackbar.showSuccessSnackbar('User updated successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to update user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      isLoading.value = true;
      await _service.deleteUser(id);
      await fetchUsers();
      snackbar.showSuccessSnackbar('User deleted successfully');
    } catch (e) {
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
}
