import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<HourlySalesData> data;

  const BarChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.brownDarker,
            tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
            //   tooltipBgColor: AppColors.brownDarker,
            // tooltipRoundedRadius: 8,
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
          rightTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].hour,
                      style: const TextStyle(
                        color: AppColors.brownNormal,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatYAxis(value.toInt()),
                  style: const TextStyle(
                    color: AppColors.brownNormal,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY() / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.brownLight,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.sales.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.brownNormal,
                    AppColors.brownNormal.withOpacity(0.7),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
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