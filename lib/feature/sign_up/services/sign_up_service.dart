import 'package:chiroku_cafe/feature/sign_up/models/sign_up_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;
  
  Future<void> signUp ({
    required String fullName,
    required String email,
    required String password, required UserRole role,
  }) async{
    try {
      
      if (email.isEmpty || password.isEmpty) {
        throw SignUpErrorModel.emptyField();
      }
      if (password.length < 6) {
        throw SignUpErrorModel.passwordTooShort();
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'email': email,
          'role': UserRole.cashier,
        });
      }

    } on AuthException catch (e) {
      throw SignUpErrorModel.fromException(e);
    } on SignUpErrorModel catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw SignUpErrorModel.unknownError();
    }
  }
}


