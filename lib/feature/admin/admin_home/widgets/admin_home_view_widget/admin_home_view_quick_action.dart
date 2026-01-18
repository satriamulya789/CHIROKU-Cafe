import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.h6.copyWith(
            color: AppColors.brownDarker,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildQuickActionItem(
                'Create New Order',
                'Start a new transaction',
                Icons.add_shopping_cart,
                AppColors.brownDarkActive,
                () => Get.toNamed('/create-order'),
              ),
              const Divider(height: 1),
              _buildQuickActionItem(
                'View All Orders',
                'Manage customer orders',
                Icons.list_alt,
                AppColors.successNormal,
                () => Get.toNamed(AppRoutes.adminReport),
              ),
              const Divider(height: 1),
              _buildQuickActionItem(
                'Manage Stock',
                'Update product inventory',
                Icons.inventory_2_outlined,
                AppColors.warningNormal,
                () => Get.toNamed(AppRoutes.adminManageControl),
              ),
              const Divider(height: 1),
              _buildQuickActionItem(
                'View Reports',
                'Check sales analytics',
                Icons.analytics_outlined,
                AppColors.blueNormal,
                () => Get.toNamed(AppRoutes.adminReport),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDarkActive,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brownNormal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}