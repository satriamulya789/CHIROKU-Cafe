import 'dart:developer';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:chiroku_cafe/utils/functions/not_register_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient supabase = Supabase.instance.client;
  final _emailNotRegister = NotRegisterEmail();
  // final _customSnackbar = CustomSnackbar();

  //sign in with email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    //validator
    final emailNotRegister = await _emailNotRegister.isEmailNotRegistered(
      email,
    );
    if (emailNotRegister) {
      throw AuthErrorModel.emailNotRegistered();
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
      // Sign in with Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      //check if user is null
      final user = response.user;
      if (user == null) {
        log('user not register');
      }
      return response;
    } catch (e) {
      log('Error sign in user');
      rethrow;
    }
  }

  Future<UserRole?> getUserRole(String userId) async {
    try {
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return null;

      final roleString = userData['role'] as String?;

      if (roleString?.toLowerCase() == 'admin') {
        return UserRole.admin;
      } else if (roleString?.toLowerCase() == 'cashier') {
        return UserRole.cashier;
      }
      return null;
    } catch (e) {
      log('Failed to load user');
      rethrow;
    }
  }

  /// Get user data from database
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final data = await supabase
          .from(ApiConstant.usersTable)
          .select('id, email, full_name, role, avatar_url')
          .eq('id', userId)
          .single();

      return data;
    } catch (e) {
      log('Failed to load user');
      rethrow;
    }
  }

  /// Check if user session exists
  Future<bool> hasActiveSession() async {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
