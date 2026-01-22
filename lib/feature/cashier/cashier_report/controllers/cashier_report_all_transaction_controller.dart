import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/repositories/cashier_report_repositories.dart';
import 'package:chiroku_cafe/shared/services/excel_service.dart';
import 'package:chiroku_cafe/shared/services/pdf_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashierAllTransactionsController extends GetxController {
  final repo = ReportCashierRepository();
  final snackbar = CustomSnackbar();

  var isLoading = false.obs;
  var allTransactions = <ReportTransaction>[].obs;
  var filteredTransactions = <ReportTransaction>[].obs;

  final searchController = TextEditingController();
  final DateTime startDate;
  final DateTime endDate;
  final String? cashierId;

  CashierAllTransactionsController({
    required this.startDate,
    required this.endDate,
    this.cashierId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchAllTransactions();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllTransactions() async {
    isLoading.value = true;
    try {
      final result = await repo.getAllTransactions(
        startDate,
        endDate,
        cashierId: cashierId,
      );

      allTransactions.value = result
          .map((json) => ReportTransaction.fromJson(json))
          .toList();
      filteredTransactions.value = allTransactions;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredTransactions.value = allTransactions;
    } else {
      filteredTransactions.value = allTransactions.where((transaction) {
        final orderId = transaction.id.toString();
        final customerName = (transaction.customerName ?? '').toLowerCase();
        final cashierName = transaction.cashierName.toLowerCase();

        return orderId.contains(query) ||
            customerName.contains(query) ||
            cashierName.contains(query);
      }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
  }

  Future<void> completeOrder(ReportTransaction transaction) async {
    try {
      isLoading.value = true;
      await repo.completeOrder(transaction.id, transaction.tableId);
      snackbar.showSuccessSnackbar('Order #${transaction.id} marked as paid');
      await fetchAllTransactions();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to complete order: $e');
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

  Future<void> exportToExcel() async {
    if (filteredTransactions.isEmpty) {
      snackbar.showErrorSnackbar('No data available to export');
      return;
    }

    try {
      isLoading.value = true;
      await ExcelService.exportTransactionsToExcel(
        filteredTransactions.toList(),
      );
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to export Excel: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
