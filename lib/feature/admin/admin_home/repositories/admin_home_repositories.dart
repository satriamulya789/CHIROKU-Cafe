import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_top_product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get total revenue and orders today
      final ordersData = await _supabase
          .from('orders')
          .select('total, order_status, created_at')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      int totalRevenue = 0;
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;

      for (var order in ordersData) {
        if (order['order_status'] == 'paid') {
          totalRevenue += (order['total'] as num).toInt();
          completedOrders++;
        } else if (order['order_status'] == 'pending') {
          pendingOrders++;
        } else if (order['order_status'] == 'cancelled') {
          cancelledOrders++;
        }
      }

      // Get hourly sales
      final hourlySales = await _getHourlySales(startOfDay, endOfDay);

      // Get top products
      final topProducts = await _getTopProducts();

      // Calculate items sold
      final itemsSold = topProducts.fold<int>(0, (sum, p) => sum + p.quantity);

      return DashboardStatsModel(
        totalRevenue: totalRevenue,
        totalOrders: ordersData.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        hourlySales: hourlySales,
        topProducts: topProducts,
        itemsSold: itemsSold,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  Future<List<HourlySalesData>> _getHourlySales(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final ordersData = await _supabase
          .from('orders')
          .select('total, created_at')
          .eq('order_status', 'paid')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());

      Map<int, HourlySalesData> hourlyMap = {};

      for (var order in ordersData) {
        final createdAt = DateTime.parse(order['created_at']);
        final hour = createdAt.hour;
        final sales = (order['total'] as num).toInt();

        if (hourlyMap.containsKey(hour)) {
          final existing = hourlyMap[hour]!;
          hourlyMap[hour] = HourlySalesData(
            hour: '${hour.toString().padLeft(2, '0')}:00',
            sales: existing.sales + sales,
            orderCount: existing.orderCount + 1,
          );
        } else {
          hourlyMap[hour] = HourlySalesData(
            hour: '${hour.toString().padLeft(2, '0')}:00',
            sales: sales,
            orderCount: 1,
          );
        }
      }

      return hourlyMap.values.toList()
        ..sort((a, b) => a.hour.compareTo(b.hour));
    } catch (e) {
      return [];
    }
  }

  Future<List<TopProductData>> _getTopProducts() async {
    try {
      final orderItemsData = await _supabase
          .from('order_items')
          .select('menu_id, qty, price, menu(name)');

      Map<int, TopProductData> productMap = {};

      for (var item in orderItemsData) {
        final menuId = item['menu_id'] as int;
        final qty = item['qty'] as int;
        final price = (item['price'] as num).toInt();
        final name = item['menu']['name'] as String;

        if (productMap.containsKey(menuId)) {
          final existing = productMap[menuId]!;
          productMap[menuId] = TopProductData(
            name: name,
            quantity: existing.quantity + qty,
            revenue: existing.revenue + (qty * price),
          );
        } else {
          productMap[menuId] = TopProductData(
            name: name,
            quantity: qty,
            revenue: qty * price,
          );
        }
      }

      final sortedProducts = productMap.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      return sortedProducts.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      List<NotificationModel> notifications = [];

      // Check pending orders
      final pendingOrders = await _supabase
          .from('orders')
          .select('id, customer_name, created_at')
          .eq('order_status', 'pending')
          .order('created_at', ascending: false)
          .limit(5);

      for (var order in pendingOrders) {
        notifications.add(
          NotificationModel(
            id: order['id'],
            type: 'order',
            title: 'New Order Received',
            message:
                'Order #${order['id']} - ${order['customer_name'] ?? 'Customer'} is waiting for confirmation',
            createdAt: DateTime.parse(order['created_at']),
          ),
        );
      }

      // Check low stock
      final lowStock = await _supabase
          .from('menu')
          .select('id, name, stock')
          .lte('stock', 5)
          .gt('stock', 0)
          .limit(3);

      for (var item in lowStock) {
        notifications.add(
          NotificationModel(
            id: item['id'],
            type: 'stock',
            title: 'Stock Running Low',
            message:
                '${item['name']} - Only ${item['stock']} units left, please reorder soon',
            createdAt: DateTime.now(),
          ),
        );
      }

      // Check out of stock
      final outOfStock = await _supabase
          .from('menu')
          .select('id, name')
          .eq('stock', 0)
          .limit(2);

      for (var item in outOfStock) {
        notifications.add(
          NotificationModel(
            id: item['id'],
            type: 'alert',
            title: 'Product Out of Stock',
            message:
                '${item['name']} is unavailable - Update menu or mark as sold out',
            createdAt: DateTime.now(),
          ),
        );
      }

      return notifications;
    } catch (e) {
      return [];
    }
  }

  Future<List<StockStatusModel>> getStockStatus() async {
    try {
      final stockData = await _supabase
          .from('menu')
          .select('id, name, stock, category_id, categories(name)')
          .order('stock', ascending: true)
          .limit(10);

      return stockData.map((item) {
        final stock = item['stock'] as int;
        String status = 'Ready';
        if (stock == 0) {
          status = 'Out of Stock';
        } else if (stock <= 5) {
          status = 'Low Stock';
        }

        return StockStatusModel(
          menuId: item['id'],
          productName: item['name'],
          category: item['categories']['name'],
          currentStock: stock,
          status: status,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
