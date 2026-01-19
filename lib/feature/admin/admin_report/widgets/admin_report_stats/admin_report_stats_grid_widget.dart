import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_stats/admin_report_stats_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsGrid extends StatelessWidget {
  final dynamic stat;
  const StatsGrid({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            StatCard(
              title: 'Total Orders',
              value: '${stat.totalOrders}',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            StatCard(
              title: 'Total Revenue',
              value: _formatCurrency(stat.totalRevenue),
              icon: Icons.attach_money,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StatCard(
              title: 'Average Revenue',
              value: _formatCurrency(stat.avgRevenue),
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            StatCard(
              title: 'Items Sold',
              value: '${stat.itemsSold}',
              icon: Icons.inventory_2,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
    String _formatCurrency(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}