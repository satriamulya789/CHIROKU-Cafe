import 'package:chiroku_cafe/feature/admin/admin_setting/models/admin_setting_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/repositories/admin_setting_repositories.dart';

class AdminSettingService {
  final AdminSettingRepository _repository = AdminSettingRepository();

  Future<AdminSettingModel?> getUserProfile() async {
    try {
      return await _repository.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserAvatarUrl() async {
    try {
      return await _repository.getUserAvatarUrl();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      await _repository.updateUserProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } catch (e) {
      rethrow;
    }
  }
}