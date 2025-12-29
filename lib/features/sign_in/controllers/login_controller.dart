import 'package:chiroku_cafe/features/sign_in/models/login_models.dart';
import 'package:chiroku_cafe/features/sign_in/repositories/login_repositories.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  // Repository
  final LoginRepository _repository = LoginRepository();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable states
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final statusMessage = Rxn<String>();
  final loginError = Rxn<LoginError>();

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check if user already logged in
  Future<void> _checkExistingSession() async {
    try {
      if (_repository.isAuthenticated()) {
        final session = _repository.getCurrentSession();
        if (session != null) {
          final role = await _getUserRole();
          _navigateToHome(role ?? 'cashier');
        }
      }
    } catch (e) {
      print('⚠️ Session check error: $e');
    }
  }

  /// Get user role
  Future<String?> _getUserRole() async {
    try {
      final user = _repository.getCurrentUser();
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        return userData?['role'] as String?;
      }
    } catch (e) {
      print('⚠️ Get role error: $e');
    }
    return null;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }
    if (!_repository.isValidEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (!_repository.isValidPassword(value)) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Login action
  Future<void> login() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Start loading
    isLoading.value = true;
    statusMessage.value = null;
    loginError.value = null;

    try {
      // Create login request
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Call repository
      final response = await _repository.signIn(request);

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Login berhasil! Selamat datang ${response.fullName ?? response.email}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Navigate based on role
      _navigateToHome(response.role);
    } on LoginError catch (e) {
      // Handle login error
      loginError.value = e;
      statusMessage.value = e.message;

      Get.snackbar(
        'Login Gagal',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } catch (e) {
      // Handle unknown error
      final errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      statusMessage.value = errorMessage;

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      // Stop loading
      isLoading.value = false;
    }
  }

  /// Navigate to home based on role
  void _navigateToHome(String role) {
    if (role.toLowerCase() == 'admin') {
      Get.offAllNamed('/homeadmin');
    } else {
      Get.offAllNamed('/homecashier');
    }
  }

  /// Navigate to forgot password
  void navigateToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  /// Navigate to register
  void navigateToRegister() {
    Get.toNamed('/register');
  }

  /// Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    statusMessage.value = null;
    loginError.value = null;
  }

  /// Quick login for development (optional)
  void quickLoginAdmin() {
    emailController.text = 'admin@chiroku.com';
    passwordController.text = 'admin123';
  }

  void quickLoginCashier() {
    emailController.text = 'cashier@chiroku.com';
    passwordController.text = 'cashier123';
  }
}