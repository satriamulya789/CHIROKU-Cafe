import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordService {
  final supabase = Supabase.instance.client;

  Future<void> sendResetEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<bool> verifyCurrentPassword(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session != null;
  }

  Future<void> updatePassword(String newPassword) async {
    final response = await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user == null) {
      log('Failed to update password for user');
    }
  }

  Future<void> verifyEmail(String email) async {
    final response = await supabase
        .from('users')
        .select('email, id')
        .eq('email', email.trim())
        .maybeSingle();

    if (response == null) {
      throw Exception('Email not registered');
    }
    log('Email exists: $email');
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // 1. Get user ID from email
    final userData = await supabase
        .from('users')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (userData == null) {
      log('Email not found in users table during reset: $email');
      throw Exception('Email not registered');
    }

    final userId = userData['id'] as String;

    // 2. Call admin RPC function to update password
    // This function must be defined in Supabase as SECURITY DEFINER
    final response = await supabase.rpc(
      'admin_update_user_password',
      params: {'user_id': userId, 'new_password': newPassword},
    );

    log('RPC admin_update_user_password response: $response');
  }
}
