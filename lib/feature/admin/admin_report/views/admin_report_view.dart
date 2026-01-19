import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/views/admin_report_top_product_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_bar_chart_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_cashier_peformance_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_product_list_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_stats_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_transaction_list_widget.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stat = controller.stat.value;

        return RefreshIndicator(
          onRefresh: controller.fetchReport,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminReportAppBar(),
                // Date Range Filter Section
                _buildDateRangeFilter(context),
                const SizedBox(height: 16),

                // Statistics Cards Section
                if (stat != null) ...[
                  // Total Revenue Highlight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.brownNormal,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brownNormal.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pendapatan',
                          style: AppTypography.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(stat.totalRevenue),
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Cards Grid
                  Row(
                    children: [
                      StatCard(
                        title: 'Total Pesanan',
                        value: '${stat.totalOrders}',
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        title: 'Total Pendapatan',
                        value: _formatCurrency(stat.totalRevenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatCard(
                        title: 'Rata-rata Pendapatan',
                        value: _formatCurrency(stat.avgRevenue),
                        icon: Icons.trending_up,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        title: 'Item Terjual',
                        value: '${stat.itemsSold}',
                        icon: Icons.inventory_2,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  // === Bar Chart Section ===
                  const SizedBox(height: 24),
                  Text('Grafik Penjualan Menu (Qty)', style: AppTypography.h5),
                  const SizedBox(height: 12),
                  ReportAdminBarChart(data: controller.productStats),
                ],

                const SizedBox(height: 24),

                // Cashier Performance Section (only if no cashier filter)
                if (controller.selectedCashierId == null) ...[
                  _buildSectionHeader(
                    icon: Icons.people,
                    title: 'Performa Kasir',
                    subtitle: 'Top kasir berdasarkan revenue & pesanan',
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
                      child: CashierPerformanceWidget(
                        cashiers: controller.cashierStats,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Top 5 Products Section
                _buildSectionHeader(
                  icon: Icons.emoji_events,
                  title: 'Top 5 Menu Terlaris',
                  subtitle: 'Berdasarkan jumlah terjual',
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
                        ProductListWidget(products: controller.top5Products),
                        if (controller.productStats.length > 5) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.to(
                                  () => TopProductsView(
                                    products: controller.top20Products,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(
                                'Lihat Top 20 Menu',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brownNormal,
                                side: BorderSide(color: AppColors.brownNormal),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recent 5 Transactions Section
                _buildSectionHeader(
                  icon: Icons.receipt_long,
                  title: 'Transaksi Terbaru',
                  subtitle: '5 transaksi terakhir',
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
                              'Lihat Semua Transaksi',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
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

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: AppColors.brownNormal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter Periode',
                  style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: AppColors.brownNormal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.dateRange != null
                            ? '${DateFormat('dd MMM yyyy').format(controller.dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(controller.dateRange!.end)}'
                            : 'Hari Ini',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.brownNormal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function untuk memilih date range
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.brownNormal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.brownDarker,
            ),
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
      controller.setDateRange(picked);
    }
  }

  // Widget untuk Section Header dengan icon dan subtitle
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brownNormal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.brownNormal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper function untuk format currency
  String _formatCurrency(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}