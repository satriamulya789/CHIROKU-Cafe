import 'package:chiroku_cafe/feature/auth/sign_in/services/sign_in_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInRepositories {
  final supabase = Supabase.instance.client;
  final _signInService = SignInService();

  Future<void> signUpUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _signInService.signIn(
        email: email,
        password: password,
      );
      final user = response.user;

      if (response.user == null) {
        throw AuthErrorModel.emailNotRegistered();
      }

      if (user != null) {
        print('User signed in: ${user.email}');
      }
    } catch (e) {
      throw e;
    }
  }
}
