import 'dart:developer';

import 'package:chiroku_cafe/feature/auth/sign_in/services/sign_in_service.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInRepositories {
  final supabase = Supabase.instance.client;
  final _signInService = SignInService();

  Future<UserRole> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        log('User sign in successfully');
      }

      // Get user profile to determine role
      final profile = await supabase
          .from('users')
          .select('role')
          .eq('id', user!.id)
          .single();

      final roleString = profile['role'] as String;

      // Convert string to UserRole enum
      return UserRole.values.firstWhere(
        (role) => role.name.toLowerCase() == roleString.toLowerCase(),
        orElse: () => UserRole.cashier,
      );
    } on AuthException catch (e) {
      log('Auth exception during sign in');
      rethrow;
    } catch (e) {
      log('Unknown error during sign in');
      rethrow;
    }
  }
}
