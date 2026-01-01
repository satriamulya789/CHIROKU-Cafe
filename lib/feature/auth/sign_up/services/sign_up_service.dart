import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;

  final ExistingEmail _existingEmail = ExistingEmail();

  /// Create User Record in users table
  Future<void> _createUserRecord({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    try {
      await supabase.from(ApiConstant.usersTable).insert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'role': 'cashier',
      });
    } catch (e) {
      print('Error creating user record: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
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
      if (fullName.isEmpty) {
        throw AuthErrorModel.nameEmpty();
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw AuthErrorModel.invalidEmailFormat();
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'email': email},
      );

      if (response.user != null) {
        await _createUserRecord(
          userId: response.user!.id,
          fullName: fullName,
          email: email,
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
