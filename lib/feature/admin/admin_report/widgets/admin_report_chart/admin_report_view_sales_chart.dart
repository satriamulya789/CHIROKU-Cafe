import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_line_chart_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_chart/admin_report_bar_chart_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_chart/admin_report_empty_chart_widget.dart';
import 'package:flutter/material.dart';

class ReportSalesChartSectionWidget extends StatefulWidget {
  final List<ReportProductStat> productData;
  final List<HourlySalesData> timeData;

  const ReportSalesChartSectionWidget({
    super.key,
    required this.productData,
    required this.timeData,
  });

  @override
  State<ReportSalesChartSectionWidget> createState() =>
      _ReportSalesChartSectionWidgetState();
}

class _ReportSalesChartSectionWidgetState
    extends State<ReportSalesChartSectionWidget> {
  String chartType = 'bar';

  @override
  Widget build(BuildContext context) {
    final hasData = widget.productData.isNotEmpty || widget.timeData.isNotEmpty;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Chart',
                style: AppTypography.h6.copyWith(
                  color: AppColors.brownDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildChartTypeToggle(),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 220,
            child: hasData
                ? (chartType == 'bar' ? _buildBarChart() : _buildLineChart())
                : _buildEmptyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
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
            isSelected: chartType == 'bar',
          ),
          _buildToggleButton(
            icon: Icons.show_chart,
            type: 'line',
            isSelected: chartType == 'line',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String type,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => chartType = type),
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

  Widget _buildBarChart() {
    return ReportAdminBarChart(data: widget.productData);
  }

  Widget _buildLineChart() {
    if (widget.timeData.isEmpty) {
      return _buildEmptyChart();
    }
    return LineChartWidget(data: widget.timeData);
  }

  Widget _buildEmptyChart() {
    return ReportEmptyChartWidget(chartType: chartType);
  }
}
