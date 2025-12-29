import 'package:chiroku_cafe/shared/models/order_models.dart';
import 'package:chiroku_cafe/shared/models/cart_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  // Cache to avoid repeated database schema checks
  static bool? _hasCustomerNameColumn;

  /// Check if customer_name column exists in orders table
  Future<bool> _hasCustomerNameSupport() async {
    if (_hasCustomerNameColumn != null) {
      return _hasCustomerNameColumn!;
    }

    try {
      // Try a simple query with customer_name to test if column exists
      await supabase
          .from('orders')
          .select('customer_name')
          .limit(1)
          .maybeSingle();
      _hasCustomerNameColumn = true;
      return true;
    } catch (e) {
      _hasCustomerNameColumn = false;
      return false;
    }
  }

  /// Create new order from cart items
  Future<OrderModel> createOrder({
    required List<CartItemModel> cartItems,
    int? tableId,
    String? customerName,
    double serviceFee = 0,
    double tax = 0,
    double discount = 0,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      // 1. Create order record first. The DB trigger (trigger_order_total)
      // will calculate subtotal and total based on inserted order_items.
      final hasCustomerName = await _hasCustomerNameSupport();

      Map<String, dynamic> orderData = {
        'user_id': userId,
        'table_id': tableId,
        'order_status': 'pending',
        // subtotal/total will be calculated by DB trigger after items inserted
        'service_fee': serviceFee,
        'tax': tax,
        'discount': discount,
        'notes': null, // Bisa diisi dari input user
      };

      // Add customer_name only if provided (don't store default 'Walk-in Customer')
      if (hasCustomerName && customerName != null && customerName.isNotEmpty) {
        orderData['customer_name'] = customerName;
      }

      final orderResponse = await supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as int;

      // If customer_name column doesn't exist but we have a customer name,
      // try to store it in a separate metadata table (optional enhancement)
      if (!hasCustomerName && customerName != null && customerName.isNotEmpty) {
        try {
          await supabase.from('order_metadata').insert({
            'order_id': orderId,
            'key': 'customer_name',
            'value': customerName,
          });
        } catch (e) {
          // If order_metadata table doesn't exist, just continue
          // Customer name won't be stored but order creation won't fail
          print('Customer name metadata not stored: $e');
        }
      }

      // 2. Create order items
      final orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'menu_id': int.parse(item.productId),
          'qty': item.quantity,
          'price': item.price,
        };
      }).toList();

  // 2. Insert order items. The order_items.subtotal is a generated column
  // (qty * price) in the DB schema; after insert, trigger will update orders.
  await supabase.from('order_items').insert(orderItemsData);

  // 3. Fetch the complete order (trigger should have updated totals)
      final completeOrder = await getOrderById(orderId);
      if (completeOrder == null) {
        // Provide a clearer error instead of letting a null-check operator throw
        throw Exception('Created order not found (order id: $orderId)');
      }

      return completeOrder;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(int orderId) async {
    try {
      final response = await supabase
          .from('orders')
          .select('''
            *, 
            tables(table_name), 
            order_items(*, menu(name, image_url)),
            users!orders_user_id_fkey(full_name, email)
          ''')
          .eq('id', orderId)
          .maybeSingle();

      if (response == null) return null;

      // If customer_name is not in response but we have metadata table, try to fetch it
      if (response['customer_name'] == null) {
        try {
          final metadataResponse = await supabase
              .from('order_metadata')
              .select('value')
              .eq('order_id', orderId)
              .eq('key', 'customer_name')
              .maybeSingle();

          if (metadataResponse != null) {
            response['customer_name'] = metadataResponse['value'];
          }
        } catch (e) {
          // Metadata table doesn't exist or query failed, continue without customer name
        }
      }

      return OrderModel.fromJson(response);
    } catch (e) {
      // Try fallback query without user relation if foreign key fails
      try {
        final response = await supabase
            .from('orders')
            .select(
              '*, tables(table_name, status), order_items(*, menu(name, image_url))',
            )
            .eq('id', orderId)
            .maybeSingle();

        if (response == null) return null;

        // Also try to fetch customer name from metadata for fallback query
        if (response['customer_name'] == null) {
          try {
            final metadataResponse = await supabase
                .from('order_metadata')
                .select('value')
                .eq('order_id', orderId)
                .eq('key', 'customer_name')
                .maybeSingle();

            if (metadataResponse != null) {
              response['customer_name'] = metadataResponse['value'];
            }
          } catch (e) {
            // Metadata table doesn't exist or query failed, continue without customer name
          }
        }

        return OrderModel.fromJson(response);
      } catch (e2) {
        throw Exception('Failed to get order: $e2');
      }
    }
  }

  /// Get all orders
  Future<List<OrderModel>> getOrders({String? status, int limit = 50}) async {
    try {
      var query = supabase
          .from('orders')
          .select(
            '*, tables(table_name, status), order_items(*, menu(name, image_url))',
          );

      if (status != null && status.isNotEmpty) {
        query = query.eq('order_status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return OrderModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  /// Update order status (implementation consolidated below)
  // Implementation removed to avoid duplicate method; a single implementation exists later in this class.

  /// Create payment and mark order as paid
  Future<PaymentModel> createPayment({
    required int orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    try {
      // 1. Create payment record
      final paymentResponse = await supabase
          .from('payments')
          .insert({
            'order_id': orderId,
            'payment_method': paymentMethod,
            'amount': amount,
          })
          .select()
          .single();

      // 2. Update order status to paid
      await updateOrderStatus(orderId, 'paid');

      return PaymentModel.fromJson(paymentResponse);
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Get payments for an order
  Future<List<PaymentModel>> getOrderPayments(int orderId) async {
    try {
      final response = await supabase
          .from('payments')
          .select()
          .eq('order_id', orderId);

      return (response as List).map((json) {
        return PaymentModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  /// Cancel order with reason and user tracking
  Future<bool> cancelOrder({required int orderId, String? reason}) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      // Check if order can be cancelled (only pending or preparing orders)
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      if (order.orderStatus != 'pending' && order.orderStatus != 'preparing') {
        throw Exception(
          'Order cannot be cancelled. Current status: ${order.orderStatus}',
        );
      }

      // Try using the database function first
      try {
        final result = await supabase.rpc(
          'cancel_order',
          params: {
            'p_order_id': orderId,
            'p_cancelled_by': userId,
            'p_reason': reason,
          },
        );

        // Best-effort: free the table if the RPC didn't
        if (order.tableId != null) {
          await _freeUpTable(order.tableId!);
        }

        return result == true;
      } catch (e) {
        // If function doesn't exist, fallback to direct update
        print('Database function not available, using direct update: $e');

        // Direct update approach
        final updateData = {
          'order_status': 'cancelled',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };

        // Try to add cancellation metadata if columns exist
        try {
          await supabase
              .from('orders')
              .update({
                ...updateData,
                'cancelled_by': userId,
                'cancelled_at': DateTime.now().toUtc().toIso8601String(),
                'cancelled_reason': reason,
              })
              .eq('id', orderId);
        } catch (e2) {
          // If advanced columns don't exist, use basic update
          await supabase.from('orders').update(updateData).eq('id', orderId);

          // Try to store cancellation info in metadata table
          try {
            if (userId != null) {
              await supabase.from('order_metadata').insert({
                'order_id': orderId,
                'key': 'cancelled_by',
                'value': userId,
              });
            }
            if (reason != null) {
              await supabase.from('order_metadata').insert({
                'order_id': orderId,
                'key': 'cancelled_reason',
                'value': reason,
              });
            }
          } catch (_) {
            // ignore metadata failures
          }
        }

        // Free the associated table if any (cancellation should release the table)
        if (order.tableId != null) {
          await _freeUpTable(order.tableId!);
        }

        return true;
      }
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Void order
  Future<void> voidOrder(int orderId) async {
    await updateOrderStatus(orderId, 'void');
  }

  /// Get active orders (pending and preparing)
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select(
            '*, tables(table_name), order_items(*, menu(name, image_url))',
          )
          .or('order_status.eq.pending,order_status.eq.preparing')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return OrderModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get active orders: $e');
    }
  }

  /// Search orders by customer name
  Future<List<OrderModel>> searchOrdersByCustomer(String customerName) async {
    try {
      var query = supabase
          .from('orders')
          .select(
            '*, tables(table_name), order_items(*, menu(name, image_url))',
          );

      // Try to search by customer_name column if it exists
      final hasCustomerName = await _hasCustomerNameSupport();
      if (hasCustomerName) {
        query = query.ilike('customer_name', '%$customerName%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(20);

      List<OrderModel> orders = (response as List).map((json) {
        return OrderModel.fromJson(json);
      }).toList();

      // If customer_name column doesn't exist, try to filter by metadata
      if (!hasCustomerName) {
        try {
          final metadataResponse = await supabase
              .from('order_metadata')
              .select('order_id')
              .eq('key', 'customer_name')
              .ilike('value', '%$customerName%');

          final orderIds = (metadataResponse as List)
              .map((item) => item['order_id'] as int)
              .toList();

          if (orderIds.isNotEmpty) {
            orders = orders
                .where((order) => orderIds.contains(order.id))
                .toList();
          } else {
            orders = [];
          }
        } catch (e) {
          // Metadata search failed, return empty list
          orders = [];
        }
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  /// Get today's orders
  Future<List<OrderModel>> getTodayOrders() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await supabase
          .from('orders')
          .select(
            '*, tables(table_name), order_items(*, menu(name, image_url))',
          )
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return OrderModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get today orders: $e');
    }
  }

  /// Get order statistics
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayOrders = await supabase
          .from('orders')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      final paidOrders = (todayOrders as List)
          .where((order) => order['order_status'] == 'paid')
          .toList();

      double totalRevenue = 0;
      for (var order in paidOrders) {
        totalRevenue += (order['total'] as num?)?.toDouble() ?? 0;
      }

      return {
        'total_orders': todayOrders.length,
        'paid_orders': paidOrders.length,
        'pending_orders': todayOrders.length - paidOrders.length,
        'total_revenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get order stats: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await supabase
          .from('orders')
          .update({
            'order_status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Complete order - mengubah status dari pending ke completed dan free up table
  Future<bool> completeOrder(int orderId) async {
    try {
      final result = await supabase.rpc(
        'complete_order',
        params: {'order_id': orderId},
      );
      return result == true;
    } catch (e) {
      // Fallback jika function tidak ada
      print('Database function not available, using direct update: $e');

      try {
        // Get order details terlebih dahulu
        final order = await getOrderById(orderId);
        if (order == null) return false;

        // Update order status to completed
        await updateOrderStatus(orderId, 'completed');

        // Free up table if exists
        if (order.tableId != null) {
          await _freeUpTable(order.tableId!);
        }

        return true;
      } catch (e2) {
        print('Error completing order: $e2');
        return false;
      }
    }
  }

  /// Reserve table saat cashier pilih meja
  Future<bool> reserveTable(int tableId) async {
    try {
      final result = await supabase.rpc(
        'reserve_table',
        params: {'table_id': tableId},
      );
      return result == true;
    } catch (e) {
      // Fallback
      try {
        await supabase
            .from('tables')
            .update({'status': 'reserved'})
            .eq('id', tableId)
            .eq('status', 'available');
        return true;
      } catch (e2) {
        print('Error reserving table: $e2');
        return false;
      }
    }
  }

  /// Occupy table saat order dibuat
  Future<bool> occupyTable(int tableId) async {
    try {
      final result = await supabase.rpc(
        'occupy_table',
        params: {'table_id': tableId},
      );
      return result == true;
    } catch (e) {
      // Fallback
      try {
        await supabase
            .from('tables')
            .update({'status': 'occupied'})
            .eq('id', tableId);
        return true;
      } catch (e2) {
        print('Error occupying table: $e2');
        return false;
      }
    }
  }

  /// Free up table saat order completed
  Future<bool> _freeUpTable(int tableId) async {
    try {
      await supabase
          .from('tables')
          .update({'status': 'available'})
          .eq('id', tableId);
      return true;
    } catch (e) {
      print('Error freeing table: $e');
      return false;
    }
  }

  /// Get sales report untuk report page
  Future<Map<String, dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now();
      final end = endDate ?? DateTime.now();

      final response = await supabase.rpc(
        'get_sales_report',
        params: {
          'start_date': start.toIso8601String().split('T')[0],
          'end_date': end.toIso8601String().split('T')[0],
        },
      );

      if (response.isNotEmpty) {
        final data = response[0];
        return {
          'total_orders': data['total_orders'] ?? 0,
          'total_revenue':
              double.tryParse(data['total_revenue'].toString()) ?? 0.0,
          'completed_orders': data['completed_orders'] ?? 0,
          'pending_orders': data['pending_orders'] ?? 0,
          'cancelled_orders': data['cancelled_orders'] ?? 0,
        };
      } else {
        return {
          'total_orders': 0,
          'total_revenue': 0.0,
          'completed_orders': 0,
          'pending_orders': 0,
          'cancelled_orders': 0,
        };
      }
    } catch (e) {
      print('Error getting sales report: $e');
      // Fallback manual calculation
      return await _getSalesReportFallback(startDate, endDate);
    }
  }

  /// Fallback sales report calculation
  Future<Map<String, dynamic>> _getSalesReportFallback(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final start = startDate ?? DateTime.now();
      final end = endDate ?? DateTime.now();
      final startOfDay = DateTime(start.year, start.month, start.day);
      final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final response = await supabase
          .from('orders')
          .select('order_status, total')
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String());

      int totalOrders = response.length;
      double totalRevenue = 0;
      int completedOrders = 0;
      int pendingOrders = 0;
      int cancelledOrders = 0;

      for (final order in response) {
        final status = order['order_status'] as String;
        final total = double.tryParse(order['total'].toString()) ?? 0;

        if (status == 'completed') {
          completedOrders++;
          totalRevenue += total;
        } else if (['pending', 'preparing', 'ready', 'paid'].contains(status)) {
          pendingOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        }
      }

      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'completed_orders': completedOrders,
        'pending_orders': pendingOrders,
        'cancelled_orders': cancelledOrders,
      };
    } catch (e) {
      throw Exception('Failed to get sales report: $e');
    }
  }

  /// Get comprehensive sales data untuk dashboard
  Future<Map<String, dynamic>> getComprehensiveSalesData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 30));
      endDate ??= DateTime.now();

      final response = await supabase
          .from('orders')
          .select('id, order_status, total, created_at, customer_name, user_id')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      // Process data
      int totalOrders = response.length;
      double totalRevenue = 0;
      double avgOrderValue = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int pendingOrders = 0;
      Map<String, int> dailyOrderCounts = {};
      Map<String, double> dailyRevenue = {};

      for (final order in response) {
        final status = order['order_status'] as String;
        final total = double.tryParse(order['total'].toString()) ?? 0;
        final createdAt = DateTime.parse(order['created_at']);
        final dateKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

        // Count by status
        if (['paid', 'completed'].contains(status)) {
          completedOrders++;
          totalRevenue += total;
        } else if (['pending', 'preparing', 'ready'].contains(status)) {
          pendingOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        }

        // Daily counts
        dailyOrderCounts[dateKey] = (dailyOrderCounts[dateKey] ?? 0) + 1;
        if (['paid', 'completed'].contains(status)) {
          dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + total;
        }
      }

      if (completedOrders > 0) {
        avgOrderValue = totalRevenue / completedOrders;
      }

      return {
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'cancelled_orders': cancelledOrders,
        'pending_orders': pendingOrders,
        'total_revenue': totalRevenue,
        'avg_order_value': avgOrderValue,
        'daily_order_counts': dailyOrderCounts,
        'daily_revenue': dailyRevenue,
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get comprehensive sales data: $e');
    }
  }

  /// Get order dengan semua detail untuk reporting
  Future<List<Map<String, dynamic>>> getOrdersWithDetails({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? userId,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase.from('orders').select('''
            id, 
            user_id,
            table_id,
            order_status,
            subtotal,
            service_fee,
            tax,
            discount,
            total,
            created_at,
            updated_at,
            customer_name,
            cancelled_by,
            cancelled_at,
            cancelled_reason,
            notes,
            tables(id, table_name),
            order_items(id, qty, price, menu(id, name, price)),
            users!orders_user_id_fkey(id, full_name, email),
            cancelled_by_user:users!orders_cancelled_by_fkey(id, full_name, email)
          ''');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      if (status != null) {
        query = query.eq('order_status', status);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get orders with details: $e');
    }
  }

  /// Get order details with items for receipt
  Future<Map<String, dynamic>?> getOrderDetailsWithItems(int orderId) async {
    try {
      final response = await supabase
          .from('orders')
          .select('''
            *,
            tables(id, table_name),
            order_items(
              id,
              qty,
              price,
              subtotal,
              menu(id, name, price)
            ),
            users!orders_user_id_fkey(id, full_name, email)
          ''')
          .eq('id', orderId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting order details with items: $e');
      return null;
    }
  }
}
