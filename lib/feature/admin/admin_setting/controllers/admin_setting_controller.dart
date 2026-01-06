import 'package:chiroku_cafe/feature/admin/admin_setting/models/admin_setting_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/services/admin_setting_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class AdminSettingController extends GetxController {
  final AdminSettingService _service = AdminSettingService();

  final Rx<AdminSettingModel?> userProfile = Rx<AdminSettingModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final profile = await _service.getUserProfile();
      
      if (profile != null) {
        userProfile.value = profile;
      } else {
        errorMessage.value = 'No user profile found';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  Future<void> logout() async {
    try {
      final confirmed = await Get.dialog<bool>(
        Get.defaultDialog(
          title: 'Logout',
          middleText: 'Are you sure you want to logout?',
          textCancel: 'Cancel',
          textConfirm: 'Logout',
          confirmTextColor: Get.theme.colorScheme.onError,
          buttonColor: Get.theme.colorScheme.error,
          onCancel: () => Get.back(result: false),
          onConfirm: () => Get.back(result: true),
        ) as Widget,
      );

      if (confirmed == true) {
        await _service.signOut();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get shortUserId {
    if (userProfile.value == null) return 'N/A';
    final id = userProfile.value!.id;
    return id.length > 8 ? '${id.substring(0, 8)}...' : id;
  }
}