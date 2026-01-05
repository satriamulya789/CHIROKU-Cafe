import 'package:chiroku_cafe/feature/auth/fotgot_password/models/forgot_password_model.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/models/reset_password_model.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  final _supabase = Supabase.instance.client;

  // Verifikasi email terdaftar
  Future<ForgotPasswordModel> verifyEmail({required String email}) async {
    try {
      // Cek apakah email ada di database
      final response = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        throw AuthErrorModel.emailNotRegistered();
      }

      // Kirim email reset password (opsional jika menggunakan Supabase Auth)
      // await _supabase.auth.resetPasswordForEmail(email);

      return ForgotPasswordModel(
        email: email,
        message: 'Email terverifikasi. Silakan reset password.',
        success: true,
      );
    } on AuthException catch (e) {
      throw AuthErrorModel.unknownError();
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }

  // Reset password
  Future<ResetPasswordModel> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validasi password match
      if (newPassword != confirmPassword) {
        throw AuthErrorModel.unknownError();
      }

      // Validasi panjang password
      if (newPassword.length < 6) {
        throw AuthErrorModel.unknownError();
      }

      // Update password di Supabase Auth (jika menggunakan)
      // await _supabase.auth.updateUser(
      //   UserAttributes(password: newPassword),
      // );

      // Atau update langsung ke database users table
      await _supabase
          .from('users')
          .update({'password': newPassword})
          .eq('email', email);

      return ResetPasswordModel(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        message: 'Password berhasil direset',
        success: true,
      );
    } on AuthException catch (e) {
      throw AuthErrorModel.unknownError();
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}