import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  //================== Dependencies ===================//
  final signUpRepository = SignUpRepository();
  final validator = Validator();
  final ExistingEmail _existingEmail = ExistingEmail();

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //================== Observables ===================//
  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;
  final _isConfirmPasswordObscured = true.obs;

  //================== Getters ===================//
  RxBool get isPasswordObscured => _isPasswordObscured;
  RxBool get isConfirmPasswordObscured => _isConfirmPasswordObscured;

  //================== Lifecycle ===================//
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  //================== Toggle Functions ===================//
  void togglePasswordVisibility() {
    _isPasswordObscured.value = !_isPasswordObscured.value;
  }
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured.value = !_isConfirmPasswordObscured.value;
  }

  //  String? validateConfirmPassword(String? value) {
  //   return validator.validateConfirmPassword(
  //     value,
  //     passwordController.text,
  //   );
  // }

  // // Opsional - Validator lainnya jika mau dipakai
  // String? validateEmail(String? value) {
  //   return validator.ValidatorEmail(value);
  // }


//================== Sign Up Function ===================//
  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
 
    if (password != confirmPassword) {
      Get.snackbar(
        'Sign Up Error',
        AuthErrorModel.passwordDontMatch().message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        borderRadius: 16,
        backgroundColor: AppColors.alertNormal,
        margin: const EdgeInsets.all(16),
        colorText: AppColors.white,
        icon: const Icon(Icons.error_outline, color: AppColors.white),
      );
      return;
    }

    isLoading.value = true;

    try {
      //email chechk exists
      final emailExists = await _existingEmail.isEmailExists(
        emailController.text.trim(),
      );

      if (emailExists) {
        Get.snackbar(
          'Sign Up Error',
          AuthErrorModel.emailAlreadyExists().message,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          borderRadius: 16,
          backgroundColor: AppColors.alertNormal,
          margin: const EdgeInsets.all(16),
          colorText: AppColors.white,
          icon: const Icon(Icons.error_outline, color: AppColors.white),
        );
        return;
      }

      await signUpRepository.registerUser(
        email: email,
        password: password,
        role: 'cashier',
      );



      Get.toNamed(AppRoutes.completeProfile);
    } catch (e) {
      Get.snackbar(
        'Error',
        AuthErrorModel.unknownError().message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        borderRadius: 16,
        backgroundColor: AppColors.alertNormal,
        margin: const EdgeInsets.all(16),
        colorText: AppColors.white,
        icon: const Icon(Icons.error_outline, color: AppColors.white),
      );
    }
  }
}
