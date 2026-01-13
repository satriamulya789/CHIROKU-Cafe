// lib/feature/admin/admin_report/controllers/admin_report_controller.dart

import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_cashier_stats_mode.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_transaction_summary_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/repositories/admin_report_repositories.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportAdminController extends GetxController {
  final repo = ReportAdminRepository();
  final snackbar = CustomSnackbar();

  var isLoading = false.obs;
  var stat = Rxn<ReportAdminStat>();
  var productStats = <ReportProductStat>[].obs;
  var cashierStats = <ReportCashierStat>[].obs;
  var recentTransactions = <ReportTransaction>[].obs;

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

      stat.value = ReportAdminStat(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        avgRevenue: avgRevenue,
        itemsSold: itemsSold,
      );

      // Product stats
      await _loadProductStats(items);

      // Cashier performance (only if no cashier filter)
      if (selectedCashierId == null) {
        await _loadCashierPerformance();
      }

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

  Future<void> _loadCashierPerformance() async {
    try {
      final orders = await repo.getCashierPerformance(startDate, endDate);

      final Map<String, ReportCashierStat> cashierMap = {};

      for (var order in orders) {
        final cashierId = order['cashier_id'] as String;
        final cashierName = order['cashier_name'] as String;
        final total = (order['total'] as num?)?.toDouble() ?? 0.0;

        if (cashierMap.containsKey(cashierId)) {
          final existing = cashierMap[cashierId]!;
          cashierMap[cashierId] = ReportCashierStat(
            cashierId: cashierId,
            cashierName: cashierName,
            totalOrders: existing.totalOrders + 1,
            totalRevenue: existing.totalRevenue + total,
            itemsSold: existing.itemsSold,
          );
        } else {
          cashierMap[cashierId] = ReportCashierStat(
            cashierId: cashierId,
            cashierName: cashierName,
            totalOrders: 1,
            totalRevenue: total,
            itemsSold: 0,
          );
        }
      }

      // Get items sold for each cashier
      for (var entry in cashierMap.entries) {
        final cashierOrders = orders
            .where((o) => o['cashier_id'] == entry.key)
            .map((o) => o['id'])
            .toList();

        if (cashierOrders.isNotEmpty) {
          final items = await repo.getOrderItems(cashierOrders);
          final itemsSold = items.fold<int>(
            0,
            (sum, item) => sum + ((item['qty'] as int?) ?? 0),
          );

          cashierMap[entry.key] = ReportCashierStat(
            cashierId: entry.value.cashierId,
            cashierName: entry.value.cashierName,
            totalOrders: entry.value.totalOrders,
            totalRevenue: entry.value.totalRevenue,
            itemsSold: itemsSold,
          );
        }
      }

      final sorted = cashierMap.values.toList()
        ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

      cashierStats.value = sorted;
    } catch (e) {
      print('Error loading cashier performance: $e');
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

  void setCashierFilter(String? cashierId) {
    selectedCashierId = cashierId;
    fetchReport();
  }

  List<ReportProductStat> get top5Products {
    final sorted = List<ReportProductStat>.from(productStats);
    sorted.sort((a, b) => b.totalQty.compareTo(a.totalQty));
    return sorted.take(5).toList();
  }

  List<ReportProductStat> get top20Products {
    final sorted = List<ReportProductStat>.from(productStats);
    sorted.sort((a, b) => b.totalQty.compareTo(a.totalQty));
    return sorted.take(20).toList();
  }
}