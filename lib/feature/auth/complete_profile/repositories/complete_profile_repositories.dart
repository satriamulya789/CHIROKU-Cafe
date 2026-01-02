import 'dart:io';
import 'package:chiroku_cafe/feature/auth/complete_profile/models/complete_profile_model.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/services/complete_profile_service.dart';

class CompleteProfileRepository {
  final _service = CompleteProfileService();

  Future<CompleteProfileModel> completeProfile({
    required String userId,
    required String fullName,
    File? avatarFile,
  }) async {
    try {
      String? avatarUrl;

      // Upload avatar if provided
      if (avatarFile != null) {
        avatarUrl = await _service.uploadAvatar(avatarFile, userId);
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
      throw Exception('Failed to complete profile: $e');
    }
  }
}