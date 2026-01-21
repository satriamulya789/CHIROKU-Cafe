import 'dart:developer';

import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_payment_setting_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_table_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/repositories/cashier_checkout_repositories.dart';
import 'package:chiroku_cafe/shared/models/cashier_error_model.dart';
import 'package:chiroku_cafe/shared/services/menu_stock_service.dart';

class CheckoutService {
  final CheckoutRepository _repository = CheckoutRepository();
  final MenuStockService _stockService = MenuStockService();

  /// Get available tables
  Future<List<TableModel>> getAvailableTables() async {
    return await _repository.getAvailableTables();
  }

  /// Get all tables
  Future<List<TableModel>> getAllTables() async {
    return await _repository.getAllTables();
  }

  /// Get table by ID
  Future<TableModel?> getTableById(int tableId) async {
    return await _repository.getTableById(tableId);
  }

  /// Reserve table (update status to 'reserved')
  Future<void> reserveTable(int tableId) async {
    await _repository.updateTableStatus(tableId, 'reserved');
  }

  /// Release table (update status to 'available')
  Future<void> releaseTable(int tableId) async {
    await _repository.updateTableStatus(tableId, 'available');
  }

  /// Get payment settings
  Future<PaymentSettingModel?> getPaymentSettings() async {
    return await _repository.getPaymentSettings();
  }

  /// Validate stock availability for all cart items
  Future<void> validateStockAvailability(List<CartItemModel> cartItems) async {
    for (final item in cartItems) {
      final hasStock = await _stockService.hasEnoughStock(
        item.menuId,
        item.quantity,
      );

      if (!hasStock) {
        final menuStock = await _stockService.checkMenuStock(item.menuId);
        final currentStock = menuStock['stock'] as int;

        throw CashierErrorModel(
          message:
              'Stok tidak cukup untuk "${item.productName}". '
              'Tersedia: $currentStock, Diminta: ${item.quantity}',
          code: 'insufficient_stock',
          statusCode: 400,
        );
      }
    }
  }

  /// Process checkout
  Future<Map<String, dynamic>> processCheckout({
    required List<CartItemModel> cartItems,
    int? tableId,
    String? customerName,
    int? discountId,
    required double subtotal,
    required double serviceFee,
    required double tax,
    required double discountAmount,
    required double total,
    required String paymentMethod,
    double? cashReceived,
    double? changeAmount,
    String? note,
    bool isPaid = true,
  }) async {
    try {
      // 0. Validate stock availability first
      await validateStockAvailability(cartItems);

      // 1. Create order
      final order = await _repository.createOrder(
        cartItems: cartItems,
        tableId: tableId,
        customerName: customerName,
        discountId: discountId,
        subtotal: subtotal,
        serviceFee: serviceFee,
        tax: tax,
        discountAmount: discountAmount,
        total: total,
        note: note,
      );

      final orderId = order['id'] as int;

      // 2. Deduct stock manually for all items
      // We do this manually here so that 'pending' orders also reduce stock.
      // NOTE: If you have a database trigger on 'paid' status, you might want to
      // disable it to avoid double-deduction, or modify it to exclude already deducted items.
      for (final item in cartItems) {
        await _stockService.deductStock(item.menuId, item.quantity);
      }

      if (isPaid) {
        // 3. Create payment
        await _repository.createPayment(
          orderId: orderId,
          paymentMethod: paymentMethod,
          amount: total,
          cashReceived: cashReceived,
          changeAmount: changeAmount,
        );

        // 4. Update order status to 'paid'
        await _repository.updateOrderStatus(orderId, 'paid');
      }

      // 4. Reserve table if selected
      if (tableId != null) {
        await reserveTable(tableId);
      }

      // 5. Fetch full order details with joined items for receipt
      final fullOrder = await _repository.getOrderDetails(orderId);

      if (fullOrder == null) {
        throw CashierErrorModel(
          message: 'Failed to fetch order details for receipt',
          code: 'fetch_order_failed',
          statusCode: 500,
        );
      }

      log('✅ Checkout processed successfully for Order #$orderId');

      // Ensure the correct status is reflected in the response
      if (isPaid) {
        fullOrder['order_status'] = 'paid';
      } else {
        fullOrder['order_status'] = 'pending';
      }

      return fullOrder;
    } catch (e) {
      log('❌ Error processing checkout: $e');
      rethrow;
    }
  }

  /// Get order details
  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    return await _repository.getOrderDetails(orderId);
  }

  /// Calculate service fee
  double calculateServiceFee(double subtotal) {
    return _repository.calculateServiceFee(subtotal);
  }

  /// Calculate tax
  double calculateTax(double subtotal) {
    return _repository.calculateTax(subtotal);
  }

  /// Calculate total
  double calculateTotal({
    required double subtotal,
    required double serviceFee,
    required double tax,
    required double discount,
  }) {
    return _repository.calculateTotal(
      subtotal: subtotal,
      serviceFee: serviceFee,
      tax: tax,
      discount: discount,
    );
  }

  /// Validate cash payment
  bool validateCashPayment(double cashReceived, double total) {
    return cashReceived >= total;
  }

  /// Calculate change
  double calculateChange(double cashReceived, double total) {
    return cashReceived - total;
  }
}
