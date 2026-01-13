import 'package:chiroku_cafe/feature/admin/admin_report/services/admin_report_service.dart';

class ReportAdminRepository {
  final ReportAdminService _service = ReportAdminService();

  Future<List<Map<String, dynamic>>> getOrders(
    DateTime start,
    DateTime end, {
    String? cashierId,
  }) {
    return _service.fetchOrders(
      start: start,
      end: end,
      cashierId: cashierId,
    );
  }

  Future<List<Map<String, dynamic>>> getOrderItems(List orderIds) {
    return _service.fetchOrderItems(orderIds);
  }

  Future<List<Map<String, dynamic>>> getCashierPerformance(
    DateTime start,
    DateTime end,
  ) {
    return _service.fetchCashierPerformance(start: start, end: end);
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
}