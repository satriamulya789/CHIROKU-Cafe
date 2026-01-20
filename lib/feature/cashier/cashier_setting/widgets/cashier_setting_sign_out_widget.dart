
import 'package:chiroku_cafe/feature/cashier/cashier_setting/controllers/cashier_setting_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignOutDialogWidget extends GetView<CashierSettingController> {
  const SignOutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.brownLight,
      title: Text('Sign Out',
        style: AppTypography.bodyLargeBold.copyWith(
          color: AppColors.brownDark,
        )
      ),
      content: Text(
        'Are you sure you want to sign out?',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.brownDark,
        ),
      ),
      actions: [
        ElevatedButton(onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.alertNormal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ), child: Text(
          'Cancel',
          style: AppTypography.buttonSmall.copyWith(color: AppColors.brownLight),
        ),
        ),
        SizedBox(width: 10),
        Obx(() {
          final loading = controller.isLoading.value;
          return ElevatedButton(
            onPressed: loading ? null : () => controller.signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Logout',
                    style: AppTypography.buttonSmall.copyWith(color: AppColors.brownLight),
                  ),
          );
        })
      ],
      

    );
  }
}