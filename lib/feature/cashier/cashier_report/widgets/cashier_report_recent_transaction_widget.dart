import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/controllers/cashier_report_controller.dart';
import 'package:chiroku_cafe/shared/widgets/report/report_section_header_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_transaction_list_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashierRecentTransactionsSection extends StatelessWidget {
  final ReportCashierController controller;
  final Function(dynamic) onTapTransaction;

  const CashierRecentTransactionsSection({
    super.key,
    required this.controller,
    required this.onTapTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReportSectionHeader(
          icon: Icons.receipt_long,
          title: 'Recent Transactions',
          subtitle: 'Last 5 transactions',
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CashierTransactionListWidget(
                  transactions: controller.recentTransactions.toList(),
                  onPrint: (t) => controller.printTransactionPDF(t),
                  onTap: onTapTransaction,
                  onDone: (t) => controller.completeOrder(t),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.cashierAllTransactions,
                        arguments: {
                          'startDate': controller.startDate,
                          'endDate': controller.endDate,
                          'cashierId': controller.selectedCashierId,
                        },
                      );
                    },
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    label: Text(
                      'View All Transactions',
                      style: AppTypography.bodyMediumBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brownNormal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
