// lib/feature/admin/admin_report/widgets/cashier_performance_widget.dart

import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_cashier_stats_mode.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashierPerformanceWidget extends StatelessWidget {
  final List<ReportCashierStat> cashiers;

  const CashierPerformanceWidget({super.key, required this.cashiers});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (cashiers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.people, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No cashier data yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cashiers.length,
      itemBuilder: (context, index) {
        final cashier = cashiers[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? (rank == 1
                          ? Colors.amber
                          : rank == 2
                          ? Colors.grey[400]
                          : Colors.brown[300])
                    : AppColors.brownNormal.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : AppColors.brownDarker,
                  ),
                ),
              ),
            ),
            title: Text(
              cashier.cashierName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${cashier.totalOrders} orders • ${cashier.itemsSold} items sold',
              style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(cashier.totalRevenue),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Revenue',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
