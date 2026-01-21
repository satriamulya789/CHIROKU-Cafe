import 'dart:developer';

import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_payment_setting_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/models/cashier_table_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/services/cashier_checkout_service.dart';
import 'package:chiroku_cafe/shared/models/cashier_error_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final CheckoutService _service = CheckoutService();
  final CustomSnackbar _snackbar = CustomSnackbar();
  final CartController cartController = Get.find<CartController>();

  // Observable states
  final RxList<TableModel> availableTables = <TableModel>[].obs;
  final Rx<TableModel?> selectedTable = Rx<TableModel?>(null);
  final RxString customerName = ''.obs;
  final RxString paymentMethod = 'cash'.obs;
  final RxDouble cashReceived = 0.0.obs;
  final RxDouble changeAmount = 0.0.obs;
  final RxBool isCashValid = true.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoadingTables = false.obs;
  final Rx<PaymentSettingModel?> paymentSettings = Rx<PaymentSettingModel?>(
    null,
  );

  // Text controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController cashController = TextEditingController();

  // Computed values from cart
  double get subtotal => cartController.subtotal;
  double get taxAmount => cartController.taxAmount;
  double get discountAmount => cartController.discountAmount;

  // Service fee (5% of subtotal)
  double get serviceFee => _service.calculateServiceFee(subtotal);

  // Total
  double get total => _service.calculateTotal(
    subtotal: subtotal,
    serviceFee: serviceFee,
    tax: taxAmount,
    discount: discountAmount,
  );

  @override
  void onInit() {
    super.onInit();
    fetchAvailableTables();
    fetchPaymentSettings();

    // Listen to cash input changes
    cashController.addListener(_onCashChanged);
  }

  @override
  void onClose() {
    customerNameController.dispose();
    cashController.dispose();
    super.onClose();
  }

  /// Fetch available tables
  Future<void> fetchAvailableTables() async {
    try {
      isLoadingTables.value = true;
      final tables = await _service.getAvailableTables();
      availableTables.assignAll(tables);
      log('✅ Loaded ${tables.length} available tables');
    } catch (e) {
      log('❌ Error fetching tables: $e');
      _snackbar.showErrorSnackbar('Failed to load tables');
    } finally {
      isLoadingTables.value = false;
    }
  }

  /// Fetch payment settings
  Future<void> fetchPaymentSettings() async {
    try {
      final settings = await _service.getPaymentSettings();
      paymentSettings.value = settings;

      if (settings?.hasQrisUrl == true) {
        log('✅ QRIS URL loaded');
      } else {
        log('⚠️ No QRIS URL configured');
      }
    } catch (e) {
      log('❌ Error fetching payment settings: $e');
    }
  }

  /// Set selected table
  void setSelectedTable(TableModel? table) {
    selectedTable.value = table;
    log('✅ Table selected: ${table?.tableName ?? "None"}');
  }

  /// Set customer name
  void setCustomerName(String name) {
    customerName.value = name;
  }

  /// Set payment method
  void setPaymentMethod(String method) {
    paymentMethod.value = method;

    // Reset cash fields when changing payment method
    if (method != 'cash') {
      cashReceived.value = 0.0;
      changeAmount.value = 0.0;
      isCashValid.value = true;
      cashController.clear();
    }

    log('✅ Payment method set to: $method');
  }

  /// Handle cash input change
  void _onCashChanged() {
    final input = cashController.text.trim();

    if (input.isEmpty) {
      cashReceived.value = 0.0;
      changeAmount.value = 0.0;
      isCashValid.value = false;
      return;
    }

    final amount = double.tryParse(input) ?? 0.0;
    cashReceived.value = amount;

    // Validate and calculate change
    isCashValid.value = _service.validateCashPayment(amount, total);
    changeAmount.value = _service.calculateChange(amount, total);
  }

  /// Validate checkout data
  bool _validateCheckout() {
    // Check if cart is empty
    if (cartController.cartItems.isEmpty) {
      _snackbar.showErrorSnackbar(CashierErrorModel.cartEmpty().message);
      return false;
    }

    // Validate cash payment
    if (paymentMethod.value == 'cash') {
      if (cashReceived.value <= 0) {
        _snackbar.showErrorSnackbar('Please enter cash amount');
        return false;
      }

      if (!isCashValid.value) {
        _snackbar.showErrorSnackbar(
          CashierErrorModel.insufficientPayment().message,
        );
        return false;
      }
    }

    // Validate QRIS payment
    if (paymentMethod.value == 'qris') {
      if (paymentSettings.value?.hasQrisUrl != true) {
        _snackbar.showErrorSnackbar(
          'QRIS is not configured. Please contact admin.',
        );
        return false;
      }
    }

    return true;
  }

  /// Show checkout confirmation dialog
  Future<void> showCheckoutConfirmation(BuildContext context) async {
    if (!_validateCheckout()) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow('Total', 'Rp ${total.toStringAsFixed(0)}'),
            _buildConfirmationRow('Metode', _getPaymentMethodLabel()),
            if (customerName.value.isNotEmpty)
              _buildConfirmationRow('Pelanggan', customerName.value),
            if (selectedTable.value != null)
              _buildConfirmationRow('Meja', selectedTable.value!.tableName),
            if (paymentMethod.value == 'cash')
              _buildConfirmationRow(
                'Kembalian',
                'Rp ${changeAmount.value.toStringAsFixed(0)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Proses'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await processCheckout();
    }
  }

  /// Process checkout
  Future<void> processCheckout() async {
    if (!_validateCheckout()) return;

    try {
      isProcessing.value = true;

      final orderData = await _service.processCheckout(
        cartItems: cartController.cartItems,
        tableId: selectedTable.value?.id,
        customerName: customerName.value.isNotEmpty ? customerName.value : null,
        discountId: cartController.selectedDiscount.value?.id,
        subtotal: subtotal,
        serviceFee: serviceFee,
        tax: taxAmount,
        discountAmount: discountAmount,
        total: total,
        paymentMethod: paymentMethod.value,
        cashReceived: paymentMethod.value == 'cash' ? cashReceived.value : null,
        changeAmount: paymentMethod.value == 'cash' ? changeAmount.value : null,
        note: cartController.orderNote.value,
      );

      // Clear cart after successful checkout
      await cartController.clearCart();

      // Reset checkout form
      _resetForm();

      // Navigate to receipt page with order data
      Get.offNamed('/cashier-receipt', arguments: orderData);

      log('✅ Checkout completed successfully');
    } catch (e) {
      log('❌ Error processing checkout: $e');

      if (e is CashierErrorModel) {
        _snackbar.showErrorSnackbar(e.message);
      } else {
        _snackbar.showErrorSnackbar(
          'Failed to process checkout. Please try again.',
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  /// Reset form
  void _resetForm() {
    selectedTable.value = null;
    customerName.value = '';
    paymentMethod.value = 'cash';
    cashReceived.value = 0.0;
    changeAmount.value = 0.0;
    isCashValid.value = true;
    customerNameController.clear();
    cashController.clear();
  }

  /// Get payment method label
  String _getPaymentMethodLabel() {
    switch (paymentMethod.value) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'card':
        return 'Kartu Debit/Kredit';
      default:
        return paymentMethod.value;
    }
  }

  /// Build confirmation row widget
  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
