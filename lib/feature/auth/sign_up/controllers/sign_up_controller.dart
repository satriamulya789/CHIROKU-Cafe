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
  //================== Repository ===================//
  final signUpRepository = SignUpRepository();

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  // final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final role = UserRole.cashier.obs;
  final validator = Validator();
  final ExistingEmail _existingEmail = ExistingEmail();

  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;
  final _isConfirmPasswordObscured = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  //================== Function ===================//

  RxBool get isPasswordObscured => _isPasswordObscured;
  RxBool get isConfirmPasswordObscured => _isConfirmPasswordObscured;

 
  void togglePasswordVisibility() {
    _isPasswordObscured.value = !_isPasswordObscured.value;
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

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured.value = !_isConfirmPasswordObscured.value;
  }

  Future<void> signUp() async {
    emailController.text = emailController.text.trim();
    passwordController.text = passwordController.text.trim();
    confirmPasswordController.text = confirmPasswordController.text.trim();

    final emailExists = await _existingEmail.isEmailExists(
      emailController.text.trim(),
    );

    if (!formKey.currentState!.validate()) return;

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

    try {
      await signUpRepository.registerUser(
      email: emailController.text,
      password: passwordController.text,
    );
      Get.toNamed(AppRoutes.signIn);
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}
