import 'dart:math';
import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/models/admin_setting_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/services/admin_setting_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class AdminSettingController extends GetxController {
  final AdminSettingService _service = AdminSettingService();
  final _customSnackBar = CustomSnackbar();

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
      final profile = await _service.getUserProfile();

      if (profile != null) {
        userProfile.value = profile;
        _customSnackBar.showInfoSnackbar(
          AuthErrorModel.loadUserSuccess().message,
        );
      } else {
        // log('No user profile found');
        _customSnackBar.showErrorSnackbar(
          AuthErrorModel.failedLoadUser().message,
        );
      }
    } catch (e) {
      log('Failed to load user profile: No data found' as num);
      _customSnackBar.showErrorSnackbar(
        AuthErrorModel.failedLoadUser().message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  void goToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  // Navigate to Printer Management
  void goToManagePrinter() {
    Get.toNamed(AppRoutes.managePrinter);
  }

  void goToManageQrisPayment() {
    Get.toNamed(AppRoutes.paymentSettings);
  }

  void goToManageDiscounts() {
    Get.toNamed(AppRoutes.adminAddDiscount);
  }

  // Navigate to Manage Control (Users, Menu, Category, Table)
  void goToManageControl() {
    Get.toNamed(AppRoutes.adminManageControl);
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get shortUserId {
    if (userProfile.value == null) return 'N/A';
    final id = userProfile.value!.id;
    return id.length > 8 ? '${id.substring(0, 8)}...' : id;
  }
}
