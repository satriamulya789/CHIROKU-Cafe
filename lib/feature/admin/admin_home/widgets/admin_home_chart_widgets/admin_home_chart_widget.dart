import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_bar_chart_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_empty_chart_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_chart_widgets/admin_home_line_chart_widget.dart';
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final List<HourlySalesData> data;
  final String chartType;

  const ChartWidget({
    super.key,
    required this.data,
    required this.chartType,
  });

  // Sample data untuk ditampilkan saat tidak ada data real
  List<HourlySalesData> get _displayData {
    if (data.isNotEmpty) return data;
    
    // Return sample data
    return [
      HourlySalesData(hour: '08:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '10:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '12:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '14:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '16:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '18:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '20:00', sales: 0, orderCount: 0),
      HourlySalesData(hour: '22:00', sales: 0, orderCount: 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: chartType == 'bar'
              ? BarChartWidget(
                  key: const ValueKey('bar'),
                  data: _displayData,
                )
              : LineChartWidget(
                  key: const ValueKey('line'),
                  data: _displayData,
                ),
        ),
        // Show overlay message when no real data
        if (data.isEmpty)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
              child: EmptyChartWidget(chartType: chartType),
            ),
          ),
      ],
    );
  }
}