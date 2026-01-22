import 'package:chiroku_cafe/feature/cashier/cashier_report/services/cashier_report_service.dart';

class ReportCashierRepository {
  final ReportCashierService _service = ReportCashierService();

  Future<List<Map<String, dynamic>>> getOrders(
    DateTime start,
    DateTime end, {
    String? cashierId,
  }) {
    return _service.fetchOrders(start: start, end: end, cashierId: cashierId);
  }

  Future<List<Map<String, dynamic>>> getOrderItems(List orderIds) {
    return _service.fetchOrderItems(orderIds);
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions(
    DateTime start,
    DateTime end, {
    String? cashierId,
    int limit = 5,
  }) {
    return _service.fetchRecentTransactions(
      start: start,
      end: end,
      cashierId: cashierId,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions(
    DateTime start,
    DateTime end, {
    String? cashierId,
    String? searchQuery,
  }) {
    return _service.fetchAllTransactions(
      start: start,
      end: end,
      cashierId: cashierId,
      searchQuery: searchQuery,
    );
  }

  Future<void> completeOrder(int orderId, int? tableId) {
    return _service.completeOrder(orderId, tableId);
  }

  Future<Map<String, dynamic>?> getOrderDetail(int orderId) {
    return _service.fetchOrderDetail(orderId);
  }
}
