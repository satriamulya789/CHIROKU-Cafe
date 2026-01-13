// lib/feature/admin/admin_report/widgets/transaction_list_widget.dart

import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_transaction_summary_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListWidget extends StatelessWidget {
  final List<ReportTransaction> transactions;

  const TransactionListWidget({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Belum ada transaksi',
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
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final paymentMethod = transaction.paymentMethod ?? 'cash';

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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                paymentMethod == 'cash'
                    ? Icons.money
                    : paymentMethod == 'qris'
                        ? Icons.qr_code
                        : Icons.credit_card,
                color: Colors.green[700],
                size: 20,
              ),
            ),
            title: Text(
              'Pesanan #${transaction.id}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.tableName != null ? 'Meja ${transaction.tableName}' : 'Tanpa Meja'} • ${DateFormat('dd MMM, HH:mm').format(transaction.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Kasir: ${transaction.cashierName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.customerName != null &&
                    transaction.customerName!.isNotEmpty)
                  Text(
                    'Customer: ${transaction.customerName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction.total),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paymentMethod.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 9,
                    ),
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