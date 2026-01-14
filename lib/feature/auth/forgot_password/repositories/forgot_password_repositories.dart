import 'package:chiroku_cafe/feature/auth/forgot_password/models/forgot_password_model.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/models/reset_password_model.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepository {
  final supabase = Supabase.instance.client;
  final _customSnackbar = CustomSnackbar();

  // Verifikasi email terdaftar
  Future<ForgotPasswordModel> verifyEmail({required String email}) async {
    try {
      // Cek apakah email ada di database
      final response = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        throw AuthErrorModel.emailNotRegistered();
      }

      // Kirim email reset password (opsional jika menggunakan Supabase Auth)
      await supabase.auth.resetPasswordForEmail(email);

      return ForgotPasswordModel(
        email: email,
        message: 'Email verification successful. Please check your inbox.',
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
        throw AuthErrorModel.passwordDontMatch();
      }

      // Validasi panjang password
      if (newPassword.length < 8) {
        throw AuthErrorModel.passwordTooShort();
      }

         // Update password langsung menggunakan updateUser
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Update password di Supabase Auth (jika menggunakan)
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );


      if (response.user == null) {
        _customSnackbar.showSuccessSnackbar( AuthErrorModel.updatePasswordFailed().message);
      }

      return ResetPasswordModel(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        message: 'Password has been reset successfully.',
        success: true,
      );
    } on AuthException catch (e) {
      throw AuthErrorModel.unknownError();
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}