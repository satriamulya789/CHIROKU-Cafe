import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/repositories/forgot_password_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  //================== Dependencies ===================//
  final _forgotPasswordRepository = ForgotPasswordRepository();
  final _customSnackbar = CustomSnackbar();
  final validator = Validator();

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //================== Observables ===================//
  final isLoading = false.obs;
  final _isNewPasswordObscured = true.obs;
  final _isConfirmPasswordObscured = true.obs;

  RxBool get isNewPasswordObscured => _isNewPasswordObscured;
  RxBool get isConfirmPasswordObscured => _isConfirmPasswordObscured;

  // Email dari halaman sebelumnya
  late String email;

  //================== Lifecycle ===================//
  @override
  void onInit() {
    super.onInit();
    // Ambil email dari arguments
    email = Get.arguments ?? '';
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  //================== Toggle Functions ===================//
  void toggleNewPasswordVisibility() {
    _isNewPasswordObscured.value = !_isNewPasswordObscured.value;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured.value = !_isConfirmPasswordObscured.value;
  }

  //================== Reset Password Function ===================//
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validasi input kosong
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.passwordEmpty().message);
      return;
    }

    // Validasi password match
    if (newPassword != confirmPassword) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.passwordDontMatch().message,
      );
      return;
    }

    // Validasi panjang password
    if (newPassword.length < 8) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.passwordTooShort().message,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _forgotPasswordRepository.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
        // Tunggu sebentar agar user bisa melihat success message
        await Future.delayed(const Duration(seconds: 2));

        // Navigate ke halaman sign in
        Get.offAllNamed(AppRoutes.signIn);

    } on AuthErrorModel catch (e) {
      // Handle specific auth errors
      _customSnackbar.showErrorSnackbar(e.message);
    } catch (e) {
      // Handle unknown errors
      _customSnackbar.showErrorSnackbar(AuthErrorModel.unknownError().message);
    } finally {
      isLoading.value = false;
    }
  }
}
