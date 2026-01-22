import 'package:supabase_flutter/supabase_flutter.dart';

class ReportCashierService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchOrders({
    required DateTime start,
    required DateTime end,
    String? cashierId,
  }) async {
    var query = supabase
        .from('orders')
        .select('id, total, created_at, order_status, cashier_id, cashier_name')
        .inFilter('order_status', [
          'paid',
          'pending',
        ]) // Include pending orders as well
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    if (cashierId != null) {
      query = query.eq('cashier_id', cashierId);
    }

    return await query;
  }

  Future<List<Map<String, dynamic>>> fetchOrderItems(List orderIds) async {
    if (orderIds.isEmpty) return [];
    return await supabase
        .from('order_items')
        .select('menu_id, qty, price, total, menu(name)')
        .inFilter('order_id', orderIds);
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions({
    required DateTime start,
    required DateTime end,
    String? cashierId,
    int limit = 5,
  }) async {
    var query = supabase
        .from('orders')
        .select('''
          id,
          total,
          order_status,
          created_at,
          table_id,
          cashier_id,
          cashier_name,
          customer_name,
          tables(table_name),
          payments(payment_method)
        ''')
        .inFilter('order_status', ['paid', 'pending'])
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    if (cashierId != null) {
      query = query.eq('cashier_id', cashierId);
    }

    return await query.order('created_at', ascending: false).limit(limit);
  }

  Future<List<Map<String, dynamic>>> fetchAllTransactions({
    required DateTime start,
    required DateTime end,
    String? cashierId,
    String? searchQuery,
  }) async {
    var query = supabase
        .from('orders')
        .select('''
          id,
          total,
          order_status,
          created_at,
          table_id,
          cashier_id,
          cashier_name,
          customer_name,
          tables(table_name),
          payments(payment_method)
        ''')
        .inFilter('order_status', ['paid', 'pending'])
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    if (cashierId != null) {
      query = query.eq('cashier_id', cashierId);
    }

    final result = await query.order('created_at', ascending: false);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      return result.where((order) {
        final orderId = order['id'].toString();
        final customerName = (order['customer_name'] as String? ?? '')
            .toLowerCase();
        final cashierName = (order['cashier_name'] as String? ?? '')
            .toLowerCase();
        final searchLower = searchQuery.toLowerCase();

        return orderId.contains(searchLower) ||
            customerName.contains(searchLower) ||
            cashierName.contains(searchLower);
      }).toList();
    }

    return result;
  }

  Future<void> completeOrder(int orderId, int? tableId) async {
    // 1. Update order status to 'paid' if it was 'pending'
    // We can just update it to 'paid' anyway to be safe, or leave it if it was already 'paid'
    await supabase
        .from('orders')
        .update({'order_status': 'paid'})
        .eq('id', orderId);

    // 2. Release table
    if (tableId != null) {
      await supabase
          .from('tables')
          .update({'status': 'available'})
          .eq('id', tableId);
    }
  }

  Future<Map<String, dynamic>?> fetchOrderDetail(int orderId) async {
    return await supabase
        .from('orders')
        .select('''
          *,
          order_items (
            *,
            menu (*)
          ),
          tables (*),
          payments (*)
        ''')
        .eq('id', orderId)
        .single();
  }
}
