import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSettingManageQrisConfirmDialogWidget extends StatelessWidget {
  final String title;
  final String message;

  const AdminSettingManageQrisConfirmDialogWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: AppTypography.h6.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.brownDark,
        ),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.brownNormal,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(
              color: AppColors.brownNormal,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.alertNormal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          child: Text(
            'Remove',
            style: AppTypography.button.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}