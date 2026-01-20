import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportEmptyChartWidget extends StatelessWidget {
  final String chartType;

  const ReportEmptyChartWidget({super.key, this.chartType = 'bar'});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dummy chart sebagai background
        Opacity(
          opacity: 0.2,
          child: chartType == 'bar'
              ? _buildDummyBarChart()
              : _buildDummyLineChart(),
        ),
        // Overlay message
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: 48,
                  color: AppColors.brownNormal.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Product Data',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.brownDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sales data by product will appear here\nwhen transactions occur',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDummyBarChart() {
    final dummyData = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.5];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
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
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < dummyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Item ${idx + 1}',
                      style: TextStyle(
                        color: AppColors.brownNormal.withOpacity(0.5),
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
                  '${(value * 100).toInt()}',
                  style: TextStyle(
                    color: AppColors.brownNormal.withOpacity(0.5),
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
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.brownLight.withOpacity(0.5),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        barGroups: dummyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: AppColors.brownNormal.withOpacity(0.3),
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

  Widget _buildDummyLineChart() {
    // Just text for line chart dummy as it's not implemented yet in the real view
    return Center(
      child: Text(
        'No Data',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.brownNormal.withOpacity(0.3),
        ),
      ),
    );
  }
}
