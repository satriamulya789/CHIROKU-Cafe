import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
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

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyChartWidget();
    }

    return AnimatedSwitcher(
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
              data: data,
            )
          : LineChartWidget(
              key: const ValueKey('line'),
              data: data,
            ),
    );
  }
}