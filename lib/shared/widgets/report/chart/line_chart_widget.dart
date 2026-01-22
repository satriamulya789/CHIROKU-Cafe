import 'package:chiroku_cafe/shared/models/report/hourly_sales_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BaseLineChartWidget extends StatelessWidget {
  final List<HourlySalesData> data;

  const BaseLineChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return LineChart(
      LineChartData(
        maxY: _getMaxY() * 1.2,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (group) => AppColors.brownDarker,
            tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < data.length) {
                  return LineTooltipItem(
                    '${data[index].hour}\n',
                    const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: 'Rp ${_formatNumber(spot.y.toInt())}\n',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '${data[index].orderCount} orders',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
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
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.sales.toDouble());
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.brownNormal,
                AppColors.brownNormal.withOpacity(0.8),
              ],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.brownNormal,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.brownNormal.withOpacity(0.25),
                  AppColors.brownNormal.withOpacity(0.01),
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
