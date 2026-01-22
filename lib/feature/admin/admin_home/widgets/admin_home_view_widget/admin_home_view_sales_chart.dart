import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/shared/widgets/report/chart/sales_chart_section_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesChartSectionWidget extends StatelessWidget {
  final DashboardStatsModel? stats;
  final RxString selectedChartType;
  final String Function(int) formatCurrency;

  const SalesChartSectionWidget({
    super.key,
    required this.stats,
    required this.selectedChartType,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SharedSalesChartSection(
        data: stats?.hourlySales ?? [],
        title: 'Sales Chart',
        subtitle: 'Today\'s sales performance',
      ),
    );
  }
}
