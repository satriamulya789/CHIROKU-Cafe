import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_chart_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
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
    if (stats == null || stats!.hourlySales.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Sales Chart',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.brownDarker,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hourly sales performance',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brownNormal,
                    ),
                  ),
                ],
              ),
              Obx(() => Container(
                    decoration: BoxDecoration(
                      color: AppColors.brownLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.bar_chart,
                            color: selectedChartType.value == 'bar'
                                ? AppColors.brownNormal
                                : AppColors.brownNormal.withOpacity(0.5),
                          ),
                          onPressed: () => selectedChartType.value = 'bar',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.show_chart,
                            color: selectedChartType.value == 'line'
                                ? AppColors.brownNormal
                                : AppColors.brownNormal.withOpacity(0.5),
                          ),
                          onPressed: () => selectedChartType.value = 'line',
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Obx(() => ChartWidget(
                  data: stats!.hourlySales,
                  chartType: selectedChartType.value,
                )),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brownLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartStat(
                  'Peak Hour',
                  stats!.hourlySales.isNotEmpty
                      ? stats!.hourlySales
                          .reduce((a, b) => a.sales > b.sales ? a : b)
                          .hour
                      : '-',
                  Icons.schedule,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.brownNormal.withOpacity(0.3),
                ),
                _buildChartStat(
                  'Average/Hour',
                  formatCurrency(
                    stats!.hourlySales.isNotEmpty
                        ? stats!.hourlySales
                                .map((e) => e.sales)
                                .reduce((a, b) => a + b) ~/
                            stats!.hourlySales.length
                        : 0,
                  ),
                  Icons.trending_up,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.brownNormal.withOpacity(0.3),
                ),
                _buildChartStat(
                  'Total Today',
                  '${stats!.totalOrders} orders',
                  Icons.shopping_cart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.brownNormal,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.brownNormal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.brownDarker,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}