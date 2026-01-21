import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/controllers/cashier_setting_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/widgets/cashier_setting_account_info_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/widgets/cashier_setting_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/widgets/cashier_setting_item_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/widgets/cashier_setting_profile_section_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/widgets/cashier_setting_sign_out_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashierSettingView extends GetView<CashierSettingController> {
  CashierSettingView({super.key});
  final _snackBar = CustomSnackbar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CashierSettingAppBarWidget(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileSectionWidget(),
                const SizedBox(height: 16),
                const AccountInfoWidget(),
                const SizedBox(height: 24),
                Text(
                  'Account Settings',
                  style: AppTypography.h6.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                SettingItemWidget(
                  icon: Icons.lock_reset,
                  title: 'Reset Password',
                  subtitle: 'Request password reset link',
                  onTap: () {
                    Get.toNamed(AppRoutes.forgotPassword);
                  },
                  iconColor: AppColors.orangeNormal,
                ),
                SettingItemWidget(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    _snackBar.showInfoSnackbar('Feature coming soon');
                  },
                  iconColor: AppColors.purpleNormal,
                ),
                const SizedBox(height: 24),
                Text(
                  'App Settings',
                  style: AppTypography.h6.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                SettingItemWidget(
                  icon: Icons.print_rounded,
                  title: 'Manage Printers',
                  subtitle: 'Configure thermal printers',
                  onTap: () {
                    Get.toNamed(AppRoutes.managePrinter);
                  },
                  iconColor: AppColors.blueNormal,
                ),
                const SizedBox(height: 24),
                Text(
                  'Other',
                  style: AppTypography.h6.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                SettingItemWidget(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: controller.contactSupport,
                  iconColor: AppColors.blueDark,
                ),
                Obx(
                  () => SettingItemWidget(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version ${controller.appVersion.value}',
                    onTap: () {
                      _showAboutAppDialog(context);
                    },
                    iconColor: AppColors.blueNormal,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const SignOutDialogWidget(),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: AppTypography.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.alertNormal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brownNormal, AppColors.brownDarker],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AssetsConstant.logo,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chiroku Cafe',
                    style: AppTypography.h5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      'Version ${controller.appVersion.value}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Elevating your cafe experience with seamless management and premium service.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Built with ❤️ for Chiroku Coffee & Roastery',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brownNormal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Close',
                        style: AppTypography.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
