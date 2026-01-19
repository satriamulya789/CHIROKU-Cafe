import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_chart_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesChartSectionWidget extends StatelessWidget {
  final DashboardStatsModel stats;
  final RxString selectedChartType;
  final String Function(double) formatCurrency;

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
                    'Sales Overview',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.brownDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Today\'s hourly sales',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brownNormal.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              _buildChartTypeToggle(),
            ],
          ),
          const SizedBox(height: 20),
          // Sales summary
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.shopping_cart,
                  label: 'Total Orders',
                  value: '${stats.totalOrders}',
                  color: AppColors.brownNormal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.attach_money,
                  label: 'Total Revenue',
                  value: formatCurrency(stats.totalRevenue.toDouble()),
                  color: AppColors.successNormal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart container dengan fixed height
          SizedBox(
            height: 250,
            child: Obx(
              () => ChartWidget(
                data: stats.hourlySales,
                chartType: selectedChartType.value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Chart legend
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.brownLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton(
              icon: Icons.bar_chart,
              type: 'bar',
              isSelected: selectedChartType.value == 'bar',
            ),
            _buildToggleButton(
              icon: Icons.show_chart,
              type: 'line',
              isSelected: selectedChartType.value == 'line',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String type,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => selectedChartType.value = type,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brownNormal : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.white : AppColors.brownNormal,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal.withOpacity(0.7),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brownLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.brownNormal.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stats.hourlySales.isEmpty
                  ? 'No sales data available yet for today'
                  : 'Peak hours: ${_getPeakHour()}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.brownNormal.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeakHour() {
    if (stats.hourlySales.isEmpty) return '-';
    final peak = stats.hourlySales.reduce((curr, next) =>
        curr.sales > next.sales ? curr : next);
    return '${peak.hour} (${formatCurrency(peak.sales.toDouble())})';
  }
}