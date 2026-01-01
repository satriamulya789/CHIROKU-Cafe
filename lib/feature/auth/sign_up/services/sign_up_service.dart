
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;

  final ExistingEmail _existingEmail = ExistingEmail();

  Future<AuthResponse> signUp(String email, String password) async {
    final emailExists = await _existingEmail.isEmailExists(email);
    if (emailExists) {
      throw AuthErrorModel.emailAlreadyExists();
    }
    if (email.isEmpty || password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (password.length < 6) {
      throw AuthErrorModel.passwordTooShort();
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw AuthErrorModel.invalidEmailFormat();
    }
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
      return response;
    } on AuthException catch (e) {
      print('AuthException: ${e.message}'); // Debug
      rethrow;
    } catch (e) {
      print('Unknown error in signUp: $e'); // Debug
      throw AuthErrorModel.unknownError();
    }
  }
}
