import 'package:chiroku_cafe/feature/auth/sign_up/services/sign_up_service.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepository {
  final supabase = Supabase.instance.client;
  final _signUpService = SignUpService();

  Future<void> registerUser({
    required String email,
    required String password,
    String role = 'cashier',
  }) async {
    try {
      final response = await _signUpService.signUp(
        email: email,
        password: password,
        role: role,
      );
      final user = response.user;

      if (user != null) {
        print('User registered: ${user.email}');
      }
    } catch (e) {
      throw e;
    }
  }
}
