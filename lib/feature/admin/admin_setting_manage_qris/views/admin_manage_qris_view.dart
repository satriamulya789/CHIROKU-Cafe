import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/controllers/admin_setting_manage_qris_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/widgets/admin_manage_qris_qris_image_card_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSettingsView extends GetView<PaymentSettingsController> {
  const PaymentSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brownDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Payment Settings',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadPaymentSettings,
          color: AppColors.brownNormal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QRIS Configuration',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.brownDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your QRIS code for customer payments',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                const SizedBox(height: 16),
                const QrisImageCardWidget(),
                const SizedBox(height: 24),
                _buildInfoCard(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.blueNormal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Information',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              '• Image will be displayed during payment',
            ),
            _buildInfoItem(
              '• Recommended size: 1024x1024 pixels',
            ),
            _buildInfoItem(
              '• Supported formats: JPG, PNG',
            ),
            _buildInfoItem(
              '• Maximum file size: 5MB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.brownNormal,
        ),
      ),
    );
  }
}