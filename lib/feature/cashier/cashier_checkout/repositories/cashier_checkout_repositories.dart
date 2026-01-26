import 'dart:developer';

import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_payment_setting_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_table_model.dart';
import 'package:chiroku_cafe/shared/models/cashier_error_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get available tables
  Future<List<TableModel>> getAvailableTables() async {
    try {
      final response = await _supabase
          .from('tables')
          .select()
          .eq('status', 'available')
          .order('table_name');

      final tables = (response as List)
          .map((json) => TableModel.fromJson(json as Map<String, dynamic>))
          .toList();

      log('✅ Fetched ${tables.length} available tables');
      return tables;
    } catch (e) {
      log('❌ Error fetching available tables: $e');
      throw CashierErrorModel.failedLoadTables();
    }
  }

  /// Get all tables
  Future<List<TableModel>> getAllTables() async {
    try {
      final response = await _supabase
          .from('tables')
          .select()
          .order('table_name');

      final tables = (response as List)
          .map((json) => TableModel.fromJson(json as Map<String, dynamic>))
          .toList();

      log('✅ Fetched ${tables.length} tables');
      return tables;
    } catch (e) {
      log('❌ Error fetching tables: $e');
      throw CashierErrorModel.failedLoadTables();
    }
  }

  /// Get table by ID
  Future<TableModel?> getTableById(int tableId) async {
    try {
      final response = await _supabase
          .from('tables')
          .select()
          .eq('id', tableId)
          .single();

      return TableModel.fromJson(response);
    } catch (e) {
      log('❌ Error fetching table by ID: $e');
      return null;
    }
  }

  /// Update table status
  Future<void> updateTableStatus(int tableId, String status) async {
    try {
      await _supabase
          .from('tables')
          .update({'status': status})
          .eq('id', tableId);

      log('✅ Table $tableId status updated to $status');
    } catch (e) {
      log('❌ Error updating table status: $e');
      throw CashierErrorModel.updateTableStatusFailed();
    }
  }

  /// Get payment settings (QRIS URL)
  Future<PaymentSettingModel?> getPaymentSettings() async {
    try {
      final response = await _supabase
          .from('payment_settings')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        log('⚠️ No payment settings found');
        return null;
      }

      return PaymentSettingModel.fromJson(response);
    } catch (e) {
      log('❌ Error fetching payment settings: $e');
      return null;
    }
  }

  /// Create order
  Future<Map<String, dynamic>> createOrder({
    required List<CartItemModel> cartItems,
    int? tableId,
    String? customerName,
    int? discountId,
    required double subtotal,
    required double serviceFee,
    required double tax,
    required double discountAmount,
    required double total,
    String? note,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw CashierErrorModel.unauthorized();
      }

      // Get cashier name
      final userResponse = await _supabase
          .from('users')
          .select('full_name')
          .eq('id', userId)
          .single();

      final cashierName = userResponse['full_name'] as String? ?? 'Unknown';

      // Create order
      final orderData = {
        'table_id': tableId,
        'cashier_id': userId,
        'cashier_name': cashierName,
        'customer_name': customerName ?? '',
        'note': note ?? '',
        'discount_id': discountId,
        'subtotal': subtotal,
        'tax': tax,
        'service_fee': serviceFee,
        'discount_applied': discountAmount,
        'total': total,
        'order_status': 'pending',
      };

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as int;

      // Create order items
      for (final item in cartItems) {
        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'menu_id': item.menuId,
          'qty': item.quantity,
          'price': item.price,
          'discount_applied': 0,
          'total': item.total,
          'note': item.note ?? '',
        });
      }

      log('✅ Order created successfully: Order #$orderId');
      return orderResponse;
    } catch (e) {
      log('❌ Error creating order: $e');
      throw CashierErrorModel.createOrderFailed();
    }
  }

  /// Create payment
  Future<void> createPayment({
    required int orderId,
    required String paymentMethod,
    required double amount,
    double? cashReceived,
    double? changeAmount,
  }) async {
    try {
      // Get payment setting ID if using QRIS
      int? paymentSettingId;
      if (paymentMethod == 'qris') {
        final settings = await getPaymentSettings();
        paymentSettingId = settings?.id;
      }

      final paymentData = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
        'payment_setting_id': paymentSettingId,
      };

      final paymentResponse = await _supabase
          .from('payments')
          .insert(paymentData)
          .select()
          .single();

      final paymentId = paymentResponse['id'] as int;

      // If cash payment, save cash details
      if (paymentMethod == 'cash' && cashReceived != null) {
        await _supabase.from('payment_cash').insert({
          'payment_id': paymentId,
          'cash_received': cashReceived,
          'change_amount': changeAmount ?? 0,
        });
      }

      log('✅ Payment created successfully for Order #$orderId');
    } catch (e) {
      log('❌ Error creating payment: $e');
      throw CashierErrorModel.paymentProcessingFailed();
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'order_status': status})
          .eq('id', orderId);

      log('✅ Order #$orderId status updated to $status');
    } catch (e) {
      log('❌ Error updating order status: $e');
      throw CashierErrorModel.updateOrderStatusFailed();
    }
  }

  /// Update order note
  Future<void> updateOrderNote(int orderId, String note) async {
    try {
      await _supabase.from('orders').update({'note': note}).eq('id', orderId);

      log('✅ Order #$orderId note updated successfully');
    } catch (e) {
      log('❌ Error updating order note: $e');
      throw CashierErrorModel(
        message: 'Failed to update order note',
        code: 'update_order_note_failed',
        statusCode: 500,
      );
    }
  }

  /// Get order details with items
  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menu (*)
            ),
            tables (*),
            users (*)
          ''')
          .eq('id', orderId)
          .single();

      return response;
    } catch (e) {
      log('❌ Error fetching order details: $e');
      return null;
    }
  }

  /// Calculate service fee (5% of subtotal)
  double calculateServiceFee(double subtotal) {
    return subtotal * 0.05;
  }

  /// Calculate tax (10% of subtotal)
  double calculateTax(double subtotal) {
    return subtotal * 0.10;
  }

  /// Calculate total
  double calculateTotal({
    required double subtotal,
    required double serviceFee,
    required double tax,
    required double discount,
  }) {
    return subtotal + serviceFee + tax - discount;
  }
}
