import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/controllers/admin_setting_manage_qris_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSettingManageQrisImageCardWidget extends GetView<PaymentSettingsController> {
  const AdminSettingManageQrisImageCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qrisUrl = controller.paymentSettings.value?.qrisUrl;
      final hasQris = qrisUrl != null && qrisUrl.isNotEmpty;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QRIS Payment',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.brownDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (controller.isUploadingImage.value)
                _buildLoadingState()
              else if (hasQris)
                _buildQrisImage(qrisUrl)
              else
                _buildEmptyState(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isUploadingImage.value
                      ? null
                      : controller.showImageSourceDialog,
                  icon: Icon(
                    hasQris ? Icons.edit : Icons.add_photo_alternate,
                    color: AppColors.white,
                  ),
                  label: Text(
                    hasQris ? 'Change QRIS Image' : 'Upload QRIS Image',
                    style: AppTypography.button.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brownNormal,
                    disabledBackgroundColor: AppColors.brownNormal.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
    });
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
            ),
            const SizedBox(height: 16),
            Text(
              'Uploading QRIS image...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.brownDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisImage(String imageUrl) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brownNormal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.alertNormal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.alertNormal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brownNormal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 64,
              color: AppColors.brownNormal.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No QRIS image uploaded',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.brownDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a QRIS image for payment',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.brownNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}