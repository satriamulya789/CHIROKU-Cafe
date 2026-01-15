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

  Future<void> resetPassword({required String email, required String newPassword}) async {
    // Implementasi sesuai kebutuhan, misal update via RPC
    final userData = await supabase
        .from('users')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (userData == null) {
      throw Exception('Email not registered');
    }

    final userId = userData['id'] as String;

    final response = await supabase.rpc(
      'admin_update_user_password',
      params: {'user_id': userId, 'new_password': newPassword},
    );

    log('Password reset via service response: $response');
  }
}