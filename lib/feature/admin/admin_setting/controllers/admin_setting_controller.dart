import 'dart:developer';
import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/models/admin_setting_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/services/admin_setting_service.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:get/get.dart';

class AdminSettingController extends GetxController {
  final AdminSettingService _service = AdminSettingService();
  final _customSnackBar = CustomSnackbar();

  final Rx<AdminSettingModel?> userProfile = Rx<AdminSettingModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadAppInfo();
  }

  Future<void> loadAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  Future<void> contactSupport() async {
    final context = Get.context;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Support',
              style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSupportOption(
              icon: Icons.email_rounded,
              title: 'Email Support',
              subtitle: 'satriamulya456@gmail.com',
              color: Colors.blue,
              onTap: () {
                Get.back();
                _launchEmail();
              },
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              icon: Icons.chat_rounded,
              title: 'WhatsApp Support',
              subtitle: '+62 812-3456-7890',
              color: Colors.green,
              onTap: () {
                Get.back();
                _launchWhatsApp();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMediumBold),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'satriamulya456@gmail.com',
      queryParameters: {'subject': 'Support Request - Chiroku Cafe'},
    );

    try {
      if (!await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      )) {
        _customSnackBar.showErrorSnackbar('Could not launch email app');
      }
    } catch (e) {
      _customSnackBar.showErrorSnackbar('Error: $e');
    }
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber = "6281234567890"; // Example number
    final String message = Uri.encodeComponent(
      "Hello Chiroku Cafe Support, I need some assistance.",
    );
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$phoneNumber?text=$message",
    );

    try {
      if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        _customSnackBar.showErrorSnackbar('Could not launch WhatsApp');
      }
    } catch (e) {
      _customSnackBar.showErrorSnackbar('Error: $e');
    }
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
      log('Failed to load user profile: No data found');
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
