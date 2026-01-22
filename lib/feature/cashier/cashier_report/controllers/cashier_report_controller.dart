import 'package:chiroku_cafe/shared/models/report/hourly_sales_model.dart';
import 'package:chiroku_cafe/shared/models/report/report_stats_model.dart';
import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/repositories/cashier_report_repositories.dart';
import 'package:chiroku_cafe/shared/services/excel_service.dart';
import 'package:chiroku_cafe/shared/services/pdf_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportCashierController extends GetxController {
  final repo = ReportCashierRepository();
  final snackbar = CustomSnackbar();

  var isLoading = false.obs;
  var stat = Rxn<ReportStat>();
  var productStats = <ReportProductStat>[].obs;
  var recentTransactions = <ReportTransaction>[].obs;
  var hourlySales = <HourlySalesData>[].obs;

  DateTimeRange? dateRange;
  String? selectedCashierId;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  DateTime get startDate {
    if (dateRange != null) return dateRange!.start;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get endDate {
    if (dateRange != null) return dateRange!.end;
    return DateTime.now();
  }

  Future<void> fetchReport() async {
    isLoading.value = true;
    try {
      final orders = await repo.getOrders(
        startDate,
        endDate,
        cashierId: selectedCashierId,
      );
      final orderIds = orders.map((e) => e['id']).toList();

      // Stats
      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(
        0.0,
        (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0.0),
      );
      final avgRevenue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      // Items sold
      final items = await repo.getOrderItems(orderIds);
      final itemsSold = items.fold<int>(
        0,
        (sum, i) => sum + ((i['qty'] as int?) ?? 0),
      );

      stat.value = ReportStat(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        avgRevenue: avgRevenue,
        itemsSold: itemsSold,
      );

      // Product stats
      await _loadProductStats(items);

      // Hourly/Daily sales for chart
      await _loadTimeSalesData(orders);

      // Recent transactions
      await _loadRecentTransactions();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to load report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProductStats(List<Map<String, dynamic>> items) async {
    final Map<int, ReportProductStat> grouped = {};
    for (var item in items) {
      final menuId = item['menu_id'] as int;
      final qty = item['qty'] as int;
      final price = (item['price'] as num).toDouble();
      final name = item['menu']?['name'] ?? 'Unknown';

      if (grouped.containsKey(menuId)) {
        grouped[menuId] = ReportProductStat(
          menuId: menuId,
          name: name,
          price: price,
          totalQty: grouped[menuId]!.totalQty + qty,
          totalRevenue: grouped[menuId]!.totalRevenue + (qty * price),
        );
      } else {
        grouped[menuId] = ReportProductStat(
          menuId: menuId,
          name: name,
          price: price,
          totalQty: qty,
          totalRevenue: qty * price,
        );
      }
    }
    productStats.value = grouped.values.toList();
  }

  Future<void> _loadTimeSalesData(List<Map<String, dynamic>> orders) async {
    try {
      final isSingleDay =
          startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day;

      Map<String, HourlySalesData> groupedMap = {};

      if (isSingleDay) {
        // Initialize all hours from 00:00 to current hour (if today) or 23:00
        final now = DateTime.now();
        final isToday =
            startDate.year == now.year &&
            startDate.month == now.month &&
            startDate.day == now.day;
        final maxHour = isToday ? now.hour : 23;

        for (int i = 0; i <= maxHour; i++) {
          final key = '${i.toString().padLeft(2, '0')}:00';
          groupedMap[key] = HourlySalesData(hour: key, sales: 0, orderCount: 0);
        }
      }

      for (var order in orders) {
        final createdAt = DateTime.parse(order['created_at']).toLocal();
        final total = (order['total'] as num?)?.toDouble() ?? 0.0;

        String key;
        if (isSingleDay) {
          key = '${createdAt.hour.toString().padLeft(2, '0')}:00';
        } else {
          key = '${createdAt.day}/${createdAt.month}';
        }

        if (groupedMap.containsKey(key)) {
          final existing = groupedMap[key]!;
          groupedMap[key] = HourlySalesData(
            hour: key,
            sales: existing.sales + total.toInt(),
            orderCount: existing.orderCount + 1,
          );
        } else {
          // For non-single day, we might not have initialized the key
          groupedMap[key] = HourlySalesData(
            hour: key,
            sales: total.toInt(),
            orderCount: 1,
          );
        }
      }

      final sorted = groupedMap.values.toList();
      if (isSingleDay) {
        sorted.sort((a, b) => a.hour.compareTo(b.hour));
      } else {
        sorted.sort((a, b) => a.hour.compareTo(b.hour));
      }

      hourlySales.value = sorted;
    } catch (e) {
      print('Error loading time sales data: $e');
    }
  }

  Future<void> _loadRecentTransactions() async {
    try {
      final result = await repo.getRecentTransactions(
        startDate,
        endDate,
        cashierId: selectedCashierId,
        limit: 5,
      );

      recentTransactions.value = result
          .map((json) => ReportTransaction.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading recent transactions: $e');
    }
  }

  void setDateRange(DateTimeRange? range) {
    dateRange = range;
    fetchReport();
  }

  List<ReportProductStat> get top5Products {
    final sorted = List<ReportProductStat>.from(productStats);
    sorted.sort((a, b) => b.totalQty.compareTo(a.totalQty));
    return sorted.take(5).toList();
  }

  Future<void> completeOrder(ReportTransaction transaction) async {
    try {
      isLoading.value = true;
      await repo.completeOrder(transaction.id, transaction.tableId);
      snackbar.showSuccessSnackbar(
        'Order #${transaction.id} completed successfully',
      );
      fetchReport();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to complete order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    try {
      isLoading.value = true;
      final result = await repo.getAllTransactions(
        startDate,
        endDate,
        cashierId: selectedCashierId,
      );

      final transactions = result
          .map((json) => ReportTransaction.fromJson(json))
          .toList();

      if (transactions.isEmpty) {
        snackbar.showErrorSnackbar('No data available to export');
        return;
      }

      await ExcelService.exportTransactionsToExcel(transactions);
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to export Excel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> printTransactionPDF(ReportTransaction transaction) async {
    try {
      isLoading.value = true;
      final items = await repo.getOrderItems([transaction.id]);
      await PdfService.generateReceiptPDF(
        transaction: transaction,
        items: items,
      );
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to print PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
