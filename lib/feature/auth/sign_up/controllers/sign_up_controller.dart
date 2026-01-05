import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
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
  final _customSnackbar = CustomSnackbar();

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

//================== Sign Up Function ===================//
  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
 
    if (password != confirmPassword) {
     _customSnackbar.showErrorSnackbar(AuthErrorModel.passwordDontMatch().message);
      return;
    }

    isLoading.value = true;

    try {
      //email chechk exists
      final emailExists = await _existingEmail.isEmailExists(
        emailController.text.trim(),
      );

      if (emailExists) {
        _customSnackbar.showSuccessSnackbar(AuthErrorModel.emailAlreadyExists().message);
        return;
      }

      await signUpRepository.registerUser(
        email: email,
        password: password,
        role: 'cashier',
      );
      Get.toNamed(AppRoutes.completeProfile);
    } catch (e) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.unknownError().message);
    }
  }
}
