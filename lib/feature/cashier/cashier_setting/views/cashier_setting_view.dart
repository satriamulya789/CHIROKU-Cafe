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
                  onTap: () {
                    _snackBar.showInfoSnackbar('Feature coming soon');
                  },
                  iconColor:
                      AppColors.blueDark ??
                      AppColors.blueNormal, // fallback if no teal defined
                ),
                SettingItemWidget(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.1.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Chiroku Cafe',
                      applicationVersion: '1.1.0',
                      applicationIcon: Image.asset(
                        AssetsConstant.logo,
                        width: 50,
                        height: 50,
                      ),
                    );
                  },
                  iconColor: AppColors.blueNormal,
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
}
