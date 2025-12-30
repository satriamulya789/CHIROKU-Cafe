import 'dart:math';
import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/sign_in/models/sign_in_model.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<UserModel> signIn(UserModel user, String password, {required String email}) async {
    try {
      // Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: user.email.trim(),
        password: user.password.trim(),
      );
      if (response.user == null) {
        throw AuthErrorModel.unknownError();
      }
      
      final data = await _client
        .from(ApiConstant.usersTable)
        .select()
        .eq('id', response.user!.id)
        .single();
    // Fetch user data from the database
  
    return UserModel.fromJson(data);


    } catch (e) {
      throw AuthErrorModel.unknownError();
      
    }
  }

  Future<UserModel?> autoLogin() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final data = await _client
        .from(ApiConstant.usersTable)
        .select('id, full_name, email, role')
        .eq('id', session.user.id)
        .single();

    return UserModel.fromJson(data);
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}