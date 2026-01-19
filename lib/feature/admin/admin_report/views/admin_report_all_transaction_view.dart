import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_all_transaction_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_recent_transaction/admin_report_transaction_list_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTransactionsView extends StatelessWidget {
  const AllTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllTransactionsController>();

    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: AppTypography.h4.copyWith(color: AppColors.brownDarker),
        ),
        backgroundColor: AppColors.brownLight,
        elevation: 0,
        foregroundColor: AppColors.brownDarker,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAllTransactions,
          ),
        ],
      ),
      body: Obx(() => Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.brownLight,
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by ID, Customer, or Cashier...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.brownNormal),
                suffixIcon: controller.searchController.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: Icon(Icons.clear, color: AppColors.brownNormal),
                        onPressed: controller.clearSearch,
                      ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brownNormal),
                ),
              ),
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.brownLight,
            child: Row(
              children: [
                Text(
                  'Showing ${controller.filteredTransactions.length} of ${controller.allTransactions.length} transactions',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchController.text.isEmpty
                                  ? 'No transactions yet'
                                  : 'No matching transactions found',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: controller.fetchAllTransactions,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            TransactionListWidget(
                              transactions: controller.filteredTransactions,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      )),
    );
  }
}