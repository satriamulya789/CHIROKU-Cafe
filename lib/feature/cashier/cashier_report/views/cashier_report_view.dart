import 'package:chiroku_cafe/feature/cashier/cashier_report/controllers/cashier_report_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_date_filter_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_revenue_card_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_stats_grid_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_recent_transaction_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/widgets/cashier_report_top_products_widget.dart';
import 'package:chiroku_cafe/shared/widgets/report/report_detail_dialog.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/widgets/report/chart/sales_chart_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportCashierView extends StatefulWidget {
  const ReportCashierView({super.key});

  @override
  State<ReportCashierView> createState() => _ReportCashierViewState();
}

class _ReportCashierViewState extends State<ReportCashierView> {
  String _selectedFilter = 'today';
  DateTimeRange? _customDateRange;

  void _onFilterSelected(String value) {
    final controller = Get.find<ReportCashierController>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _selectedFilter = value;
      _customDateRange = null;
    });

    if (value == 'today') {
      controller.setDateRange(
        DateTimeRange(start: today, end: today.add(const Duration(days: 1))),
      );
    } else if (value == 'week') {
      controller.setDateRange(
        DateTimeRange(start: today.subtract(const Duration(days: 7)), end: now),
      );
    } else if (value == 'month') {
      controller.setDateRange(
        DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      );
    } else if (value == 'all') {
      controller.setDateRange(DateTimeRange(start: DateTime(2020), end: now));
    }
  }

  Future<void> _onCustomDateRangeTap() async {
    final picked = await showDateRangePopup(context, _customDateRange);
    if (picked != null) {
      setState(() {
        _selectedFilter = 'custom';
        _customDateRange = picked;
      });
      Get.find<ReportCashierController>().setDateRange(picked);
    }
  }

  void _showTransactionDetails(dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => ReportDetailDialog(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportCashierController>();
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: CashierReportAppBar(onExportTap: controller.exportToExcel),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.fetchReport,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Date Filter Section ---
                CashierTransactionDateFilterSection(
                  selectedFilter: _selectedFilter,
                  customDateRange: _customDateRange,
                  onFilterSelected: _onFilterSelected,
                  onCustomDateRangeTap: _onCustomDateRangeTap,
                ),
                const SizedBox(height: 16),
                if (controller.stat.value != null) ...[
                  CashierTotalRevenueCard(stat: controller.stat.value!),
                  CashierStatsGrid(stat: controller.stat.value!),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SharedSalesChartSection(
                      data: controller.hourlySales.toList(),
                      title: 'Sales Chart',
                      subtitle: 'Operational sales performance',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                CashierTopProductsSection(controller: controller),
                const SizedBox(height: 24),
                CashierRecentTransactionsSection(
                  controller: controller,
                  onTapTransaction: _showTransactionDetails,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}
