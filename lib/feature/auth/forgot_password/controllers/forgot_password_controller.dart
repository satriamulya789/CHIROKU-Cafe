import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/repositories/forgot_password_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  //================== Dependencies ===================//
  final forgotPasswordRepository = ForgotPasswordRepository();
  final _customSnackbar = CustomSnackbar();
  final validator = Validator();

  //================== Form Controllers ===================//
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  //================== Observables ===================//
  final isLoading = false.obs;

  //================== Lifecycle ===================//
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  //================== Verify Email Function ===================//
  Future<void> verifyEmail() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.emailEmpty().message);
      return;
    }

    isLoading.value = true;
    try {
      final result = await forgotPasswordRepository.verifyEmail(email: email);

      if (result.success) {
        _customSnackbar.showSuccessSnackbar(result.message);
        // Navigate ke halaman reset password dengan email
        Get.toNamed(AppRoutes.resetPassword, arguments: email);
      } else {
        _customSnackbar.showErrorSnackbar(
          AuthErrorModel.emailNotRegistered().message,
        );
      }
    } catch (e) {
      _customSnackbar.showErrorSnackbar(AuthErrorModel.unknownError().message);
    } finally {
      isLoading.value = false;
    }
  }
}
