import 'dart:developer';
import 'package:chiroku_cafe/feature/auth/forgot_password/models/forgot_password_model.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/models/reset_password_model.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/services/forgot_password_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  final supabase = Supabase.instance.client;
  final _service = ForgotPasswordService();

  /// Verify if email is registered
  Future<ForgotPasswordModel> verifyEmail({required String email}) async {
    try {
      // Validasi email format
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw AuthErrorModel.invalidEmailFormat();
      }
      await _service.verifyEmail(email);

      // Cek apakah email ada di database
      final response = await supabase
          .from('users')
          .select('email, id')
          .eq('email', email.trim())
          .maybeSingle();

      if (response == null) {
        throw AuthErrorModel.emailNotRegistered();
      }

      log('Email verified successfully: $email');

      return ForgotPasswordModel(
        email: email,
        message:
            'Email verified successfully. You can now reset your password.',
        success: true,
      );
    } on AuthErrorModel catch (e) {
      log('Auth error during email verification: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unknown error during email verification: $e');
      throw AuthErrorModel.unknownError();
    }
  }

  /// Reset password for verified email
  Future<ResetPasswordModel> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validasi password match
      if (newPassword != confirmPassword) {
        throw AuthErrorModel.passwordDontMatch();
      }

      // Validasi panjang password
      if (newPassword.length < 8) {
        throw AuthErrorModel.passwordTooShort();
      }
      await _service.resetPassword(email: email, newPassword: newPassword);

      // Get user ID from email
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('email', email.trim())
          .maybeSingle();

      if (userData == null) {
        throw AuthErrorModel.emailNotRegistered();
      }

      final userId = userData['id'] as String;

      // Update password menggunakan RPC function
      final response = await supabase.rpc(
        'admin_update_user_password',
        params: {'user_id': userId, 'new_password': newPassword},
      );

      log('Password update response: $response');

      return ResetPasswordModel(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } on AuthErrorModel catch (e) {
      log('Auth error during password reset: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      log('Supabase error during password reset: ${e.message}');
      throw AuthErrorModel.unknownError();
    } catch (e) {
      log('Unknown error during password reset: $e');
      throw AuthErrorModel.unknownError();
    }
  }
}
