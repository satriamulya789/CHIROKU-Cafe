import 'dart:io';

import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/models/complete_profile_model.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      // generate a unique file name
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'avatars/$fileName';

      // Upload file to Supabase Storage
      await supabase.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw AuthErrorModel.uploadAvatarFailed();
    }
  }

  //update user profile in database
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
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
  Future<CompleteProfileModel> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from(ApiConstant.usersTable)
          .select('id, full_name, avatar_url, created_at, updated_at')
          .eq('id', userId)
          .single();

      if (response == null) {
        throw AuthErrorModel.failedLoadUser();
      }
      ;

      return CompleteProfileModel.fromJson(response);
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
