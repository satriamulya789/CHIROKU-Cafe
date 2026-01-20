import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/models/cashier_setting_models.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/services/cashier_setting_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class CashierSettingController extends GetxController {
  final CashierSettingService _service = CashierSettingService();
  final _customSnackBar = CustomSnackbar();

  final Rx<CashierSettingModel?> userProfile = Rx<CashierSettingModel?>(null);
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

  // SignOUt
  Future<void> signOut() async {
    try {
      await _service.signOut();
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      _customSnackBar.showErrorSnackbar(AuthErrorModel.signoutError().message);
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