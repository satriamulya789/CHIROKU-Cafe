import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_stats_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportSalesChartSectionWidget extends StatefulWidget {
  final List<ReportProductStat> data;

  const ReportSalesChartSectionWidget({
    super.key,
    required this.data,
  });

  @override
  State<ReportSalesChartSectionWidget> createState() => _ReportSalesChartSectionWidgetState();
}

class _ReportSalesChartSectionWidgetState extends State<ReportSalesChartSectionWidget> {
  String chartType = 'bar';

  @override
  Widget build(BuildContext context) {
    final hasData = widget.data.isNotEmpty;

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
                ? (chartType == 'bar'
                    ? _buildBarChart()
                    : _buildLineChart())
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
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: widget.data.take(7).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final stat = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: stat.totalQty.toDouble(),
                color: AppColors.brownNormal,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < widget.data.length) {
                  return Text(
                    widget.data[idx].name.length > 8
                        ? widget.data[idx].name.substring(0, 8) + '...'
                        : widget.data[idx].name,
                    style: AppTypography.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildLineChart() {
    // Dummy line chart for product stats (you can customize this)
    return Center(
      child: Text(
        'Line chart not implemented for product stats.',
        style: AppTypography.bodySmall.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Text(
        'No product sales data yet',
        style: AppTypography.bodyMedium.copyWith(color: Colors.grey),
      ),
    );
  }
}