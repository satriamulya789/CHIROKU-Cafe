import 'dart:io';
import 'package:chiroku_cafe/feature/auth/complete_profile/models/complete_profile_model.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/services/complete_profile_service.dart';
import 'package:chiroku_cafe/shared/models/handling_error_model.dart';

class CompleteProfileRepository {
  final _service = CompleteProfileService();


  //get user data
  Future<CompleteProfileModel?> getUserProfile(String userId) async {
    try {
      final data = await _service.getUserProfile(userId);
      if (data == null) return null;

      return CompleteProfileModel.fromJson(data.toJson());
    } catch (e) {
      throw AuthErrorModel.updateProfileFailed();
      
      }
  }

// Upload avatar only
  Future<String?> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    try {
      final avatarUrl = await _service.uploadAvatar(userId, avatarFile);
      return avatarUrl;
    } catch (e) {
      throw AuthErrorModel.uploadAvatarFailed();
    }
  }
  
//complete profile with avatar upload
  Future<CompleteProfileModel> completeProfile({
    required String userId,
    required String fullName,
    File? avatarFile,
  }) async {
    try {
      String? avatarUrl;

      // Upload avatar if provided
      if (avatarFile != null) {
        avatarUrl = await _service.uploadAvatar(userId,avatarFile);
      }

      // Update user profile
      await _service.updateUserProfile(
        userId: userId,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      return CompleteProfileModel(
        userId: userId,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      throw Exception(AuthErrorModel.failedLoadUser());
    }
  }


  //update user profile
}