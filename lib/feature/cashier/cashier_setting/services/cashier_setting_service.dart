import 'package:chiroku_cafe/feature/cashier/cashier_setting/models/cashier_setting_models.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/repositories/cashier_setting_repositories.dart';

class CashierSettingService {
  final CashierSettingRepository _repository = CashierSettingRepository();

  Future<CashierSettingModel?> getUserProfile() async {
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