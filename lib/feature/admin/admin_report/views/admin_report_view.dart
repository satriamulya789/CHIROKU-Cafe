import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_date_range_filter_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_stats/admin_report_stats_grid_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_top_revenue_card_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_chart/admin_report_sales_chart_section_widget.dart';
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
    setState(() {
      _selectedFilter = value;
      // TODO: Call controller/filter data here if needed
    });
  }

  Future<void> _onCustomDateRangeTap() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.brownNormal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.brownDarker,
            ),
            dialogBackgroundColor: AppColors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brownNormal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFilter = 'custom';
        _customDateRange = picked;
        // TODO: Call controller/filter data here if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportAdminController>();
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AdminReportAppBar(),
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
                  SalesChartSection(controller: controller),
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