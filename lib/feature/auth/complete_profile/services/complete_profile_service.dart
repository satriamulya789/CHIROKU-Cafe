import 'dart:io';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'avatars/$fileName';

      //Upload file to Supabase Storage
      await supabase.storage
          .from(ApiConstant.avatarsUrl)
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabase.storage
          .from(ApiConstant.avatarsUrl)
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw AuthErrorModel.uploadAvatar();
    }
  }

  //update user profile in database
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      await supabase
          .from(ApiConstant.usersTable)
          .update({
            'full_name': fullName,
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw AuthErrorModel.updateProfileFailed();
    }
  }

  //Get current user
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from(ApiConstant.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Delete avatar from storage
  Future<void> deleteAvatar(String avatarPath) async {
    try {
      await supabase.storage.from(ApiConstant.avatarsUrl).remove([avatarPath]);
    } catch (e) {
      throw AuthErrorModel.deleteAvatar();
    }
  }
}
