import 'package:chiroku_cafe/feature/sign_up/services/sign_up_service.dart';
import 'package:chiroku_cafe/feature/sign_up/models/sign_up_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepository {
  final SignUpService _signUpService;

  SignUpRepository(this._signUpService);

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
      throw SignUpErrorModel.fromException(e);
    } on SignUpErrorModel catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw SignUpErrorModel.unknownError();
    }
  }
}