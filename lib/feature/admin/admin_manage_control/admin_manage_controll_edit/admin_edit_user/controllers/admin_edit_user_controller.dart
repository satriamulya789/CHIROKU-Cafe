import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/services/admin_edit_user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditUserController extends GetxController {
  final UserService _service = UserService();

  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final roleController = TextEditingController(text: 'cashier');

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
    roleController.dispose();
    super.onClose();
  }

  List<UserModel> get filteredUsers {
    if (searchQuery.value.isEmpty) return users;
    return users.where((user) {
      return user.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (user.email?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _service.fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
      Get.snackbar(
        'Success', 
        'User created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        role: roleController.text,
      );
      await fetchUsers();
      clearForm();
      Get.back();
      Get.snackbar(
        'Success', 
        'User updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      isLoading.value = true;
      await _service.deleteUser(id);
      await fetchUsers();
      Get.snackbar(
        'Success', 
        'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateCreateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Full name is required', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Password is required', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    return true;
  }

  bool _validateUpdateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Full name is required', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (emailController.text.trim().isNotEmpty && 
        !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    return true;
  }

  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    roleController.text = 'cashier';
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}