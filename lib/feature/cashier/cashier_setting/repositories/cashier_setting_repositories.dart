import 'package:chiroku_cafe/feature/cashier/cashier_setting/models/cashier_setting_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashierSettingRepository {
  final supabase = Supabase.instance.client;

  /// Get current user profile
  Future<CashierSettingModel?> getUserProfile() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (response == null) return null;

      return CashierSettingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Get avatar URL from storage
  Future<String?> getUserAvatarUrl() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await supabase
          .from('users')
          .select('avatar_url')
          .eq('id', currentUser.id)
          .maybeSingle();

      return response?['avatar_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await supabase.from('users').update({
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}