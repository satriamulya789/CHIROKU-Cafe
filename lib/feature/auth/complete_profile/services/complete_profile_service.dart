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

      await supabase.storage
          .from(ApiConstant.avatarsUrl)
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabase.storage.from(ApiConstant.avatarsUrl).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw AuthErrorModel.uploadAvatar();
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async{
    try {
      
    } catch (e) {
      
    }
  }
}
