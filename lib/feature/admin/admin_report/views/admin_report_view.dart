import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_chart/admin_report_view_sales_chart.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_date_range_filter_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_stats/admin_report_stats_grid_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_top_revenue_card_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_cashier_peformance/admin_report_cashier_performance_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_top_sales_product_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_recent_transaction/admin_report_recent_transaction_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportAdminView extends StatefulWidget {
  const ReportAdminView({super.key});

  @override
  State<ReportAdminView> createState() => _ReportAdminViewState();
}

class _ReportAdminViewState extends State<ReportAdminView> {
  String _selectedFilter = 'today';
  DateTimeRange? _customDateRange;

  void _onFilterSelected(String value) {
    final controller = Get.find<ReportAdminController>();
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
      Get.find<ReportAdminController>().setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportAdminController>();
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AdminReportAppBar(onExportTap: controller.exportToExcel),
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
                TransactionDateFilterSection(
                  selectedFilter: _selectedFilter,
                  customDateRange: _customDateRange,
                  onFilterSelected: _onFilterSelected,
                  onCustomDateRangeTap: _onCustomDateRangeTap,
                ),
                const SizedBox(height: 16),
                if (controller.stat.value != null) ...[
                  TotalRevenueCard(stat: controller.stat.value!),
                  const SizedBox(height: 12),
                  StatsGrid(stat: controller.stat.value!),
                  const SizedBox(height: 24),
                  ReportSalesChartSectionWidget(
                    productData: controller.productStats,
                    timeData: controller.hourlySales,
                  ),
                  const SizedBox(height: 24),
                ],
                if (controller.selectedCashierId == null) ...[
                  CashierPerformanceSection(controller: controller),
                  const SizedBox(height: 24),
                ],
                TopProductsSection(controller: controller),
                const SizedBox(height: 24),
                RecentTransactionsSection(controller: controller),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}
