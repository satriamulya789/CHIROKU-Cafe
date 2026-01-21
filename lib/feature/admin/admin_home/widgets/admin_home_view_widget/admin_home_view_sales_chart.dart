import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_top_product_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_empty_chart_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Chart',
                style: AppTypography.h6.copyWith(
                  color: AppColors.brownDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildChartTypeToggle(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Obx(() {
              final data = stats?.topProducts ?? [];
              if (data.isEmpty) {
                return EmptyChartWidget(chartType: selectedChartType.value);
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedChartType.value == 'bar'
                    ? _buildProductBarChart(data)
                    : _buildProductLineChart(data),
              );
            }),
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
          _buildToggleButton(Icons.bar_chart, 'bar'),
          _buildToggleButton(Icons.show_chart, 'line'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, String type) {
    return Obx(() {
      final isSelected = selectedChartType.value == type;
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
    });
  }

  Widget _buildProductBarChart(List<TopProductData> data) {
    final displayData = data.take(7).toList();
    final maxY = displayData.isEmpty
        ? 100.0
        : displayData
                  .map((e) => e.revenue.toDouble())
                  .reduce((a, b) => a > b ? a : b) *
              1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.brownDarker,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = displayData[group.x.toInt()];
              return BarTooltipItem(
                '${item.name}\n${formatCurrency(item.revenue)}\n${item.quantity} sold',
                const TextStyle(color: Colors.white, fontSize: 10),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < displayData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      displayData[idx].name.length > 5
                          ? '${displayData[idx].name.substring(0, 5)}..'
                          : displayData[idx].name,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.brownNormal,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                if (value >= 1000000)
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: const TextStyle(fontSize: 8),
                  );
                if (value >= 1000)
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 8),
                  );
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 8),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: displayData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.revenue.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.brownNormal,
                    AppColors.brownNormal.withOpacity(0.7),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductLineChart(List<TopProductData> data) {
    final displayData = data.take(10).toList();
    final maxY = displayData.isEmpty
        ? 100.0
        : displayData
                  .map((e) => e.revenue.toDouble())
                  .reduce((a, b) => a > b ? a : b) *
              1.2;

    return LineChart(
      LineChartData(
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.brownDarker,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final item = displayData[spot.x.toInt()];
                return LineTooltipItem(
                  '${item.name}\n${formatCurrency(item.revenue)}',
                  const TextStyle(color: Colors.white, fontSize: 10),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < displayData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      displayData[idx].name.length > 5
                          ? '${displayData[idx].name.substring(0, 5)}..'
                          : displayData[idx].name,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.brownNormal,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                if (value >= 1000000)
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: const TextStyle(fontSize: 8),
                  );
                if (value >= 1000)
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 8),
                  );
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 8),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: displayData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.revenue.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: AppColors.brownNormal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.brownNormal.withOpacity(0.3),
                  AppColors.brownNormal.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
