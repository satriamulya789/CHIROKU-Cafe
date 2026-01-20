import 'dart:io';
import 'package:chiroku_cafe/feature/cashier/cashier_edit_profile/models/cashier_edit_profile_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_edit_profile/services/cashier_edit_profile_service.dart';

class CashierUserProfileRepository {
  final CashierUserProfileService _service = CashierUserProfileService();

  Future<CashierUserProfileModel> getUserProfile(String userId) async {
    try {
      final data = await _service.getUserProfile(userId);
      return CashierUserProfileModel.fromJson(data);
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
      await _service.updateUserProfile(
        userId: userId,
        fullName: fullName,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String?> uploadAndUpdateAvatar({
    required String userId,
    required File imageFile,
    String? oldAvatarUrl,
  }) async {
    try {
      final bucketExists = await _service.checkBucketExists();
      if (!bucketExists) {
        throw Exception(
          'Storage bucket "avatars" does not exist. Please create it in Supabase Storage.',
        );
      }

      if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
        await _service.deleteOldAvatar(oldAvatarUrl);
      }

      final String? newAvatarUrl = await _service.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );

      if (newAvatarUrl != null) {
        await _service.updateAvatarUrl(userId: userId, avatarUrl: newAvatarUrl);
      }

      return newAvatarUrl;
    } catch (e) {
      throw Exception('Failed to upload and update avatar: $e');
    }
  }
}
