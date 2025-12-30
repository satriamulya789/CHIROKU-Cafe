import 'package:chiroku_cafe/feature/sign_up/services/sign_up_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepository {
  final SignUpService _signUpService = SignUpService();

  SignUpRepository(SignUpService find);


  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      await _signUpService.signUp(
        fullName: fullName,
        email: email,
        password: password,
        role: UserRole.cashier,
      );
    } on AuthException catch (e) {
      throw AuthErrorModel.fromException(e);
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}