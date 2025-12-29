import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/printer_model.dart';
import '../controllers/thermal_printer_controller.dart';

/// Helper service untuk mencetak struk dari mana saja
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  /// Get thermal printer controller
  ThermalPrinterController get _controller {
    // Try to get existing controller
    if (Get.isRegistered<ThermalPrinterController>()) {
      return Get.find<ThermalPrinterController>();
    } else {
      // Create and register controller if not exists
      return Get.put(ThermalPrinterController());
    }
  }

  /// Quick check if printer is connected
  Future<bool> isConnected() async {
    try {
      return await _controller.checkConnection();
    } catch (e) {
      return false;
    }
  }

  /// Print receipt - main method to use
  Future<bool> printReceipt(ReceiptData receiptData) async {
    try {
      final bool connected = await isConnected();
      
      if (!connected) {
        // Show dialog to setup printer
        final bool? shouldSetup = await Get.dialog<bool>(
          _PrinterNotConnectedDialog(),
          barrierDismissible: false,
        );

        if (shouldSetup == true) {
          // Navigate to printer settings
          await Get.toNamed('/printer-settings');
          
          // Check again after returning
          final bool nowConnected = await isConnected();
          if (!nowConnected) {
            return false;
          }
        } else {
          return false;
        }
      }

      // Print the receipt
      return await _controller.printReceipt(receiptData);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Quick print helper untuk transaksi kasir
  Future<bool> printTransactionReceipt({
    required String receiptNumber,
    required String cashierName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    double tax = 0,
    double discount = 0,
    required double total,
    required double cash,
    required double change,
    String? notes,
  }) async {
    final receiptItems = items.map((item) {
      return ReceiptItem(
        name: item['name'] ?? '',
        quantity: item['quantity'] ?? 0,
        price: (item['price'] ?? 0).toDouble(),
        subtotal: (item['subtotal'] ?? 0).toDouble(),
      );
    }).toList();

    final receiptData = ReceiptData(
      receiptNumber: receiptNumber,
      dateTime: DateTime.now(),
      cashierName: cashierName,
      items: receiptItems,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      cash: cash,
      change: change,
      notes: notes,
    );

    return await printReceipt(receiptData);
  }

  /// Navigate to printer settings
  void openPrinterSettings() {
    Get.toNamed('/printer-settings');
  }

  /// Get current printer info
  BluetoothPrinter? get currentPrinter => _controller.selectedPrinter.value;

  /// Get connection status
  PrinterConnectionStatus get connectionStatus =>
      _controller.connectionStatus.value;
}

/// Dialog ketika printer belum terhubung
class _PrinterNotConnectedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Printer Tidak Terhubung'),
      content: const Text(
        'Printer thermal belum terhubung. Apakah Anda ingin mengatur printer sekarang?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Atur Printer'),
        ),
      ],
    );
  }
}
