import 'package:chiroku_cafe/features/forgot_passoword/models/forgot_passowrd_model.dart';
import 'package:chiroku_cafe/features/forgot_passoword/repositories/forgot_password_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordRepository _repository = ForgotPasswordRepository();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final statusMessage = Rxn<String>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }
    if (!_repository.isValidEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  Future<void> verifyEmail() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    statusMessage.value = null;

    try {
      final request = ForgotPasswordRequest(
        email: emailController.text.trim(),
      );

      final response = await _repository.verifyEmail(request);

      if (!response.emailExists) {
        statusMessage.value =
            'Email tidak ditemukan. Periksa kembali email Anda.';
        Get.snackbar(
          'Email Tidak Ditemukan',
          'Email tidak terdaftar. Silakan periksa kembali.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Email found, show success message
      Get.snackbar(
        'Email Ditemukan',
        'Email terverifikasi. Lanjutkan reset password.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Navigate to reset password page with email
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed('/reset-password', arguments: {'email': response.email});
    } on PasswordError catch (e) {
      statusMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      statusMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      Get.snackbar(
        'Error',
        statusMessage.value!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin() {
    Get.back();
  }
}