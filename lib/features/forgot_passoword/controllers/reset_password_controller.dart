import 'package:chiroku_cafe/features/forgot_passoword/models/forgot_passowrd_model.dart';
import 'package:chiroku_cafe/features/forgot_passoword/repositories/forgot_password_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final ForgotPasswordRepository _repository = ForgotPasswordRepository();

  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final statusMessage = Rxn<String>();

  // Password strength
  final passwordStrength = PasswordStrength.empty.obs;
  final passwordCriteria = <String, bool>{
    'length': false,
    'lowercase': false,
    'uppercase': false,
    'digit': false,
    'symbol': false,
  }.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('email')) {
      email = args['email'] ?? '';
    } else {
      email = '';
    }
    newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void onClose() {
    newPasswordController.removeListener(_updatePasswordStrength);
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _updatePasswordStrength() {
    passwordStrength.value =
        PasswordValidator.checkStrength(newPasswordController.text);
    passwordCriteria.value =
        PasswordValidator.getCriteria(newPasswordController.text);
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  String? validateNewPassword(String? value) {
    return PasswordValidator.validate(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != newPasswordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    statusMessage.value = null;

    try {
      final request = ResetPasswordRequest(
        email: email,
        newPassword: newPasswordController.text,
      );

      await _repository.resetPassword(request);

      Get.snackbar(
        'Berhasil',
        'Password berhasil direset!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Navigate to login after delay
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/login');
    } on PasswordError catch (e) {
      statusMessage.value = e.message;
      Get.snackbar(
        'Gagal',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      statusMessage.value = 'Gagal mereset password: ${e.toString()}';
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
}