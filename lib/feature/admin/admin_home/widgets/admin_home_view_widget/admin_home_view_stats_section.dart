import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_stats_card_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatsSectionWidget extends StatelessWidget {
  final DashboardStatsModel? stats;
  final String Function(int) formatCurrency;

  const StatsSectionWidget({
    super.key,
    required this.stats,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                title: 'Total Sales Today',
                value: formatCurrency(stats!.totalRevenue),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.pinkNormal,
                backgroundColor: AppColors.white,
                onTap: () => Get.toNamed(AppRoutes.adminReport),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                title: 'Completed Orders',
                value: stats!.completedOrders.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.successNormal,
                backgroundColor: AppColors.white,
                onTap: () => Get.toNamed('/orders'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                title: 'Pending Orders',
                value: stats!.pendingOrders.toString(),
                icon: Icons.pending_outlined,
                color: AppColors.warningNormal,
                backgroundColor: AppColors.white,
                onTap: () => Get.toNamed('/orders?status=pending'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                title: 'Cancelled',
                value: stats!.cancelledOrders.toString(),
                icon: Icons.cancel_outlined,
                color: AppColors.alertNormal,
                backgroundColor: AppColors.white,
                onTap: () => Get.toNamed('/orders?status=cancelled'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}