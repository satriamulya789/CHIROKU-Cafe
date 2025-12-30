import 'package:chiroku_cafe/feature/sign_up/models/sign_up_response.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
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
    await supabase.from('users').insert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'role': 'cashier',
    });
  } catch (e) {
    throw AuthErrorModel.unknownError();    
  }
}

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,

    required String password, required UserRole role,
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
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}


