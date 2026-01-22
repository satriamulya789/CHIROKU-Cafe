import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashierTransactionListWidget extends StatelessWidget {
  final List<ReportTransaction> transactions;
  final Function(ReportTransaction)? onPrint;
  final Function(ReportTransaction)? onTap;
  final Function(ReportTransaction)? onDone;

  const CashierTransactionListWidget({
    super.key,
    required this.transactions,
    this.onPrint,
    this.onTap,
    this.onDone,
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
                'No transactions yet',
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
        final isPending = transaction.orderStatus == 'pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: onTap != null ? () => onTap!(transaction) : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.orange[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPending
                              ? Icons.hourglass_empty
                              : (paymentMethod == 'cash'
                                    ? Icons.money
                                    : paymentMethod == 'qris'
                                    ? Icons.qr_code
                                    : Icons.credit_card),
                          color: isPending
                              ? Colors.orange[700]
                              : Colors.green[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${transaction.id}',
                              style: AppTypography.bodyMediumBold.copyWith(
                                color: AppColors.brownDarker,
                              ),
                            ),
                            Text(
                              '${transaction.tableName != null ? 'Table ${transaction.tableName}' : 'No Table'} • ${DateFormat('dd MMM, HH:mm').format(transaction.createdAt)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(transaction.total),
                            style: AppTypography.bodyMediumBold.copyWith(
                              color: isPending
                                  ? Colors.orange[700]
                                  : Colors.green[700],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.orange[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPending
                                  ? 'PENDING'
                                  : paymentMethod.toUpperCase(),
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isPending
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onPrint != null)
                        TextButton.icon(
                          onPressed: () => onPrint!(transaction),
                          icon: const Icon(Icons.print_outlined, size: 18),
                          label: const Text('Print'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.brownNormal,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      const SizedBox(width: 8),
                      // "Done" button
                      if (isPending)
                        ElevatedButton.icon(
                          onPressed: onDone != null
                              ? () => onDone!(transaction)
                              : null,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
