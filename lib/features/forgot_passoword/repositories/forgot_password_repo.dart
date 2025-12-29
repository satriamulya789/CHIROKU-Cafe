import 'package:chiroku_cafe/features/forgot_passoword/models/forgot_passowrd_model.dart';
import 'package:chiroku_cafe/shared/repositories/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Verify if email exists in database
  Future<ForgotPasswordResponse> verifyEmail(
      ForgotPasswordRequest request) async {
    try {
      // Check if email exists using AuthService
      final emailExists = await _authService.isEmailExists(request.email);

      return ForgotPasswordResponse(
        emailExists: emailExists,
        email: request.email,
        message: emailExists ? 'Email ditemukan' : 'Email tidak terdaftar',
      );
    } catch (e) {
      print('❌ ForgotPasswordRepository verifyEmail error: $e');
      throw PasswordError.fromException(e);
    }
  }

  /// Reset password using Supabase auth
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      // Update password for the authenticated user
      await _supabase.auth.updateUser(
        UserAttributes(
          password: request.newPassword,
        ),
      );
    } catch (e) {
      print('❌ ForgotPasswordRepository resetPassword error: $e');
      throw PasswordError.fromException(e);
    }
  }

  /// Send password reset email (alternative method using Supabase)
  Future<void> sendResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'chiroku-cafe://reset-password',
      );
    } catch (e) {
      print('❌ ForgotPasswordRepository sendResetEmail error: $e');
      throw PasswordError.fromException(e);
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return PasswordValidator.isValidEmail(email);
  }

  /// Validate password
  bool isValidPassword(String password) {
    return PasswordValidator.validate(password) == null;
  }
}