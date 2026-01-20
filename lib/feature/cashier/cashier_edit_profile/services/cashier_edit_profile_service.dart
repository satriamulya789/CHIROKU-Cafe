import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashierUserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({
            'full_name': fullName,
            'email': email,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '$userId/$fileName';

      final bytes = await imageFile.readAsBytes();

      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update avatar URL: $e');
    }
  }

  Future<void> deleteOldAvatar(String? oldAvatarUrl) async {
    if (oldAvatarUrl == null || oldAvatarUrl.isEmpty) return;

    try {
      final Uri uri = Uri.parse(oldAvatarUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3) {
        final userId = pathSegments[pathSegments.length - 2];
        final fileName = pathSegments[pathSegments.length - 1];
        final filePath = '$userId/$fileName';

        final files = await _supabase.storage
            .from('avatars')
            .list(path: userId);

        final fileExists = files.any((file) => file.name == fileName);

        if (fileExists) {
          await _supabase.storage.from('avatars').remove([filePath]);
        }
      }
    } catch (e) {
      print('Failed to delete old avatar: $e');
    }
  }

  Future<bool> checkBucketExists() async {
    try {
      await _supabase.storage.from('avatars').list();
      return true;
    } catch (e) {
      return false;
    }
  }
}
