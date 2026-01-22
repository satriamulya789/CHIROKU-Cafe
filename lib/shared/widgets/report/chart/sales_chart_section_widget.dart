import 'package:chiroku_cafe/shared/models/report/hourly_sales_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/report/chart/bar_chart_widget.dart';
import 'package:chiroku_cafe/shared/widgets/report/chart/empty_chart_widget.dart';
import 'package:chiroku_cafe/shared/widgets/report/chart/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SharedSalesChartSection extends StatelessWidget {
  final List<HourlySalesData> data;
  final String title;
  final String subtitle;

  const SharedSalesChartSection({
    super.key,
    required this.data,
    this.title = 'Sales Statistics',
    this.subtitle = 'Sales performance over time',
  });

  @override
  Widget build(BuildContext context) {
    final RxBool isLineChart = true.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLargeBold.copyWith(
                    color: AppColors.brownDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.greyNormal,
                  ),
                ),
              ],
            ),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: AppColors.brownLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildToggleButton(
                      icon: Icons.show_chart_rounded,
                      isActive: isLineChart.value,
                      onTap: () => isLineChart.value = true,
                    ),
                    _buildToggleButton(
                      icon: Icons.bar_chart_rounded,
                      isActive: !isLineChart.value,
                      onTap: () => isLineChart.value = false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.only(right: 16),
          child: data.isEmpty
              ? const EmptyChartWidget()
              : Obx(
                  () => isLineChart.value
                      ? BaseLineChartWidget(data: data)
                      : BaseBarChartWidget(data: data),
                ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brownNormal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : AppColors.brownNormal,
        ),
      ),
    );
  }
}
