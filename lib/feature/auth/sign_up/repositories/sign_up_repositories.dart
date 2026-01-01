
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepository {
  final supabase = Supabase.instance.client;

  Future<void> registerUser({ required String email, required String password }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': UserRole.cashier},
      );
      final user = response.user;

      if (user != null) {
        Get.snackbar(
          'Sign Up Successful',
          AuthErrorModel.successAccount().message,
          colorText: AppColors.white,
          backgroundColor: AppColors.alertNormal,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          borderRadius: 16,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Sign Up Error',
        AuthErrorModel.unknownError().message,
        colorText: AppColors.white,
        backgroundColor: AppColors.alertNormal,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        borderRadius: 16,
      );
    }
  }
}
