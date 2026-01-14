import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  /// Success snackbar - for successful operations
  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.successNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Success',
        style: AppTypography.h5.copyWith(color: AppColors.white),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
      ),
    );
  }

  /// Error snackbar - for error messages
  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.alertNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Error',
        style: AppTypography.h5.copyWith(color: AppColors.white),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
      ),
    );
  }

  /// Warning snackbar - for warning messages
  void showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: AppColors.warningNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.warning_amber_outlined, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Warning',
        style: AppTypography.h5.copyWith(color: AppColors.white),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
      ),
    );
  }

  /// Info snackbar - for informational messages
  void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: AppColors.infoNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.info_outline, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Info',
        style: AppTypography.h5.copyWith(color: AppColors.white),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
      ),
    );
  }
}
