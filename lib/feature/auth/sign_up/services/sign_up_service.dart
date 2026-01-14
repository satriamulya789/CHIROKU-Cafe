import 'dart:developer';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/functions/existing_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final SupabaseClient supabase = Supabase.instance.client;
  final ExistingEmail _existingEmail = ExistingEmail();

  /// Create user record in table 'users'
  Future<void> _createUserRecord({
    required String userId,
    required String email,
  }) async {
    try {
      await supabase.from(ApiConstant.usersTable).insert({
        'id': userId,
        'email': email.trim().toLowerCase(),
        'role': 'cashier',
        'created_at': DateTime.now().toIso8601String(),
      });

      log(
        'User record created successfully',
      );
    } catch (e) {
      log(
        'Error creating user record'
      );
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    // Validation
    final emailExists = await _existingEmail.isEmailExists(email);
    if (emailExists) {
      throw AuthErrorModel.emailAlreadyExists();
    }
    if (password.isEmpty) {
      throw AuthErrorModel.passwordEmpty();
    }
    if (email.isEmpty) {
      throw AuthErrorModel.emailEmpty();
    }
    if (password.length < 6) {
      throw AuthErrorModel.passwordTooShort();
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw AuthErrorModel.invalidEmailFormat();
    }

    try {
      final response = await supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {'role': role},
      );

      final user = response.user;
      if (user != null) {
        await _createUserRecord(userId: user.id, email: email);

        log(
          'User signed up successfully: ${user.email}',
          name: 'SignUpService.signUp',
          level: 800,
        );
      }

      return response;
    } on AuthException catch (e) {
      log(
        'Auth exception during sign up',
        name: 'SignUpService.signUp',
        error: e,
        level: 1000,
      );
      rethrow;
    } catch (e) {
      log(
        'Unknown error during sign up',
        name: 'SignUpService.signUp',
        error: e,
        level: 1000,
      );
      rethrow;
    }
  }
}
