import 'package:chiroku_cafe/feature/admin/admin_setting/controllers/admin_setting_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountInfoWidget extends GetView<AdminSettingController> {
  const AccountInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.userProfile.value;
      if (profile == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blueNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Account Information',
                  style: AppTypography.h6.copyWith(fontWeight: FontWeight.w700, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: controller.shortUserId,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: controller.formatDate(profile.createdAt),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}