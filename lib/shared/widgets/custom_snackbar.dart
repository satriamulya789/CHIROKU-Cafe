import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CustomSnackbar {
  //success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.successNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Success',
        style: AppTypography.h6.copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }

  // error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.alertNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        'Error',
        style: AppTypography.h6.copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }


}