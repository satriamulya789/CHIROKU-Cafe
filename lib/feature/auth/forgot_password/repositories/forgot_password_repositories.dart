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
      // 1. Validasi email format
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw AuthErrorModel.invalidEmailFormat();
      }

      log('Attempting to verify email: $email');

      // 2. Cek apakah email ada di database (via service)
      await _service.verifyEmail(email);

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
      log('Unexpected error during email verification: $e');
      // Jika errornya dari service "Email not registered"
      if (e.toString().contains('Email not registered')) {
        throw AuthErrorModel.emailNotRegistered();
      }
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
      // 1. Validasi password match
      if (newPassword != confirmPassword) {
        throw AuthErrorModel.passwordDontMatch();
      }

      // 2. Validasi panjang password
      if (newPassword.length < 8) {
        throw AuthErrorModel.passwordTooShort();
      }

      log('Attempting to reset password for email: $email');

      // 3. Perform reset via service
      await _service.resetPassword(email: email, newPassword: newPassword);

      log('Password reset successfully completed for: $email');

      return ResetPasswordModel(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } on AuthErrorModel catch (e) {
      log('Auth error during password reset: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      log(
        'Supabase/Postgres error during password reset: ${e.message} (Code: ${e.code})',
      );
      throw AuthErrorModel.unknownError();
    } catch (e) {
      log('Unexpected error during password reset: $e');
      throw AuthErrorModel.unknownError();
    }
  }
}
