import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cashier_stats_model.dart';

class CashierRepository {
  final _supabase = Supabase.instance.client;

  /// Get statistik dashboard cashier
  Future<CashierStats> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get orders hari ini
      final ordersResponse = await _supabase
          .from('orders')
          .select('id, order_status, total')
          .gte('created_at', today.toIso8601String());

      int totalOrders = ordersResponse.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      double totalRevenue = 0;

      for (var order in ordersResponse) {
        final status = order['order_status']?.toString().toLowerCase() ?? '';

        if (status == 'pending' || status == 'preparing') {
          pendingOrders++;
        } else if (status == 'completed' || status == 'paid') {
          completedOrders++;
          totalRevenue += (order['total'] as num?)?.toDouble() ?? 0;
        }
      }

      // Get table statistics
      final tablesResponse = await _supabase
          .from('tables')
          .select('id, status');

      int tablesOccupied = 0;
      int tablesAvailable = 0;

      for (var table in tablesResponse) {
        final status = table['status']?.toString().toLowerCase() ?? '';
        if (status == 'reserved' || status == 'occupied') {
          tablesOccupied++;
        } else if (status == 'available') {
          tablesAvailable++;
        }
      }

      return CashierStats(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        totalRevenue: totalRevenue,
        tablesOccupied: tablesOccupied,
        tablesAvailable: tablesAvailable,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  /// Get pending orders count
  Future<int> getPendingOrdersCount() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id')
          .or('order_status.eq.pending,order_status.eq.preparing');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get today's revenue
  Future<double> getTodayRevenue() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final response = await _supabase
          .from('orders')
          .select('total')
          .or('order_status.eq.paid,order_status.eq.completed')
          .gte('created_at', today.toIso8601String());

      double total = 0;
      for (var order in response) {
        total += (order['total'] as num?)?.toDouble() ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Stream untuk realtime updates
  Stream<CashierStats> watchDashboardStats() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      return await getDashboardStats();
    });
  }
}
