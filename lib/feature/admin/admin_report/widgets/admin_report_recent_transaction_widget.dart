import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_section_header_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_transaction_list_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentTransactionsSection extends StatelessWidget {
  final ReportAdminController controller;
  const RecentTransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
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
                TransactionListWidget(
                  transactions: controller.recentTransactions,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.adminAllTransactions,
                        arguments: {
                          'startDate': controller.startDate,
                          'endDate': controller.endDate,
                          'cashierId': controller.selectedCashierId,
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                    ),
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

