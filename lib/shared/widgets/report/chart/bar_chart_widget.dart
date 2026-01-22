import 'package:chiroku_cafe/shared/models/report/hourly_sales_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BaseBarChartWidget extends StatelessWidget {
  final List<HourlySalesData> data;

  const BaseBarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.brownDarker,
            tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()].hour}\n',
                const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: 'Rp ${_formatNumber(rod.toY.toInt())}\n',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '${data[group.x.toInt()].orderCount} orders',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();

                // Only show labels every 4 hours to avoid overlapping
                // Always show the last point if it's significant
                if (index % 4 != 0 && index != data.length - 1) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    data[index].hour,
                    style: TextStyle(
                      color: AppColors.brownNormal.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatYAxis(value.toInt()),
                    style: TextStyle(
                      color: AppColors.brownNormal.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY() / 4 > 0 ? _getMaxY() / 4 : 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.brownLight.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.sales.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.brownNormal,
                    AppColors.brownNormal.withOpacity(0.6),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: data.length > 20 ? 8 : 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _getMaxY() * 1.2,
                  color: AppColors.brownLight.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    return data.map((e) => e.sales).reduce((a, b) => a > b ? a : b).toDouble();
  }

  String _formatYAxis(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toString();
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
