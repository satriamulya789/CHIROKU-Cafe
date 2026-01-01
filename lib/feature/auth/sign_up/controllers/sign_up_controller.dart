import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpController extends GetxController {
  //================== Repository ===================//
  final SignUpRepository _signUpRepository;

  SignUpController(this._signUpRepository);

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final role = 'cashier'.obs;
  final ExistingEmail _existingEmail = ExistingEmail();

  final isLoading = false.obs;
  final _isPasswordObscured = true.obs;

  //================== Function ===================//

  RxBool get isPasswordObscured => _isPasswordObscured;
  void togglePasswordVisibility() {
    _isPasswordObscured.value = !_isPasswordObscured.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    

    isLoading.value = true;

    //email already exists check
    final emailExists = await _existingEmail.isEmailExists(
      emailController.text.trim(),
    );

    try {
       await _signUpRepository.registerUser(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
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
     

      Get.toNamed(AppRoutes.signIn);
    } catch (e) {
      final error = e is AuthErrorModel
          ? e
          : AuthErrorModel.fromException(e as AuthException);
      Get.snackbar('Sign Up Error', error.message);
    }
  }
}
