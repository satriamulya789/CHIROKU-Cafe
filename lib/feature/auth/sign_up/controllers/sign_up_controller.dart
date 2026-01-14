import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final passwordText = ''.obs; // For reactive password requirement widget

  //================== Getters ===================//
  RxBool get isPasswordObscured => _isPasswordObscured;
  RxBool get isConfirmPasswordObscured => _isConfirmPasswordObscured;

  //================== Lifecycle ===================//
  @override
  void onInit() {
    super.onInit();
    // Listen to password changes for reactive UI updates
    passwordController.addListener(() {
      passwordText.value = passwordController.text;
    });
  }

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
    // Validate form
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Check password match
    if (password != confirmPassword) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.passwordDontMatch().message,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Check if email already exists
      final emailExists = await _existingEmail.isEmailExists(email);

      if (emailExists) {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.emailAlreadyExists().message,
        );
        isLoading.value = false;
        return;
      }

      // Register user
      await signUpRepository.registerUser(
        email: email,
        password: password,
        role: 'cashier',
      );

      // Success - navigate to complete profile
      _customSnackbar.showSuccessSnackbar(
        AuthErrorModel.accountCreatedSuccess().message,
      );

      Get.toNamed(AppRoutes.completeProfile);
    } on AuthException catch (e) {
      // Handle Supabase authentication errors
      final error = AuthErrorModel.fromException(e);
      _customSnackbar.showErrorSnackbar(error.message);
    } on AuthErrorModel catch (e) {
      // Handle custom auth errors from service layer
      _customSnackbar.showErrorSnackbar(e.message);
    } catch (e) {
      // Handle unknown errors
      final errorMessage = e.toString();

      // Check for network errors
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException') ||
          errorMessage.contains('Failed host lookup')) {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.networkError().message,
        );
      } else {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.unknownError().message,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
