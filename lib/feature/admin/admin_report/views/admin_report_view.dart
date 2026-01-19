import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/views/admin_report_top_product_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_bar_chart_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_cashier_peformance_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_cashier_performance_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_date_range_filter_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_product_list_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_recent_transaction_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_sales_chart_section_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_stats_grid_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_top_revenue_card_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_top_sales_product_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportAdminView extends GetView<ReportAdminController> {
  const ReportAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AdminReportAppBar(
      ),
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
                DateRangeFilterWidget(controller: controller),
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




 
