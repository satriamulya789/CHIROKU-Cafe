import 'package:chiroku_cafe/features/thermal_printer/controllers/thermal_printer_controller.dart';
import 'package:chiroku_cafe/features/thermal_printer/models/printer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrinterSettingsPage extends GetView<ThermalPrinterController> {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada arguments untuk auto print
    final args = Get.arguments as Map<String, dynamic>?;
    final bool autoConnect = args?['autoConnect'] ?? false;

    // Auto scan saat pertama kali buka
    if (autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scanForPrinters();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan Printer',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => controller.isScanning.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.scanForPrinters,
                  tooltip: 'Pindai Printer',
                )),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Card
          Obx(() => _buildConnectionStatusCard()),

          // Available Printers List
          Expanded(
            child: Obx(() {
              if (controller.isScanning.value &&
                  controller.availableDevices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Mencari printer...',
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                );
              }

              if (controller.availableDevices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_disabled,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada printer ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pastikan printer sudah dipasangkan\ndi pengaturan Bluetooth',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.scanForPrinters,
                        icon: const Icon(Icons.search),
                        label: Text(
                          'Pindai Printer',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableDevices.length,
                itemBuilder: (context, index) {
                  final printer = controller.availableDevices[index];
                  return _buildPrinterCard(printer);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.connectionStatus.value ==
            PrinterConnectionStatus.connected) {
          return FloatingActionButton.extended(
            onPressed: controller.testPrint,
            icon: controller.isPrinting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.print),
            label: Text(
              'Test Print',
              style: GoogleFonts.poppins(),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildConnectionStatusCard() {
    final status = controller.connectionStatus.value;
    final printer = controller.selectedPrinter.value;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case PrinterConnectionStatus.connected:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Terhubung';
        break;
      case PrinterConnectionStatus.connecting:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Menghubungkan...';
        break;
      case PrinterConnectionStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.bluetooth_disabled;
        statusText = 'Tidak Terhubung';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                if (printer != null)
                  Text(
                    printer.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          if (status == PrinterConnectionStatus.connected)
            TextButton(
              onPressed: controller.disconnectPrinter,
              child: Text(
                'Putuskan',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrinterCard(BluetoothPrinter printer) {
    final args = Get.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? printData = args?['printData'];
    
    final isSelected = controller.selectedPrinter.value?.macAddress ==
        printer.macAddress;
    final isConnected = controller.connectionStatus.value ==
            PrinterConnectionStatus.connected &&
        isSelected;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isConnected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isConnected ? Icons.print : Icons.print_outlined,
            color: isConnected ? Colors.green : Colors.blue,
            size: 28,
          ),
        ),
        title: Text(
          printer.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              printer.macAddress,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (isConnected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Terhubung',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: Obx(() {
          if (controller.connectionStatus.value ==
                  PrinterConnectionStatus.connecting &&
              isSelected) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (isConnected) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (printData != null)
                  ElevatedButton.icon(
                    onPressed: () => _printReceiptFromData(printData),
                    icon: const Icon(Icons.print, size: 16),
                    label: Text(
                      'Cetak',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: controller.disconnectPrinter,
                ),
              ],
            );
          }

          return ElevatedButton(
            onPressed: () async {
              final connected = await controller.connectToPrinter(printer);
              // Auto print jika ada print data dan berhasil connect
              if (connected && printData != null) {
                await Future.delayed(const Duration(milliseconds: 500));
                _printReceiptFromData(printData);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hubungkan',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _printReceiptFromData(Map<String, dynamic> printData) async {
    try {
      // Convert items dari Map ke ReceiptItem
      final items = (printData['items'] as List<dynamic>).map((item) {
        return ReceiptItem(
          name: item['name'] ?? '',
          quantity: item['quantity'] ?? 0,
          price: (item['price'] as num?)?.toDouble() ?? 0.0,
          subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      // Create ReceiptData
      final receiptData = ReceiptData(
        receiptNumber: printData['receiptNumber'] ?? '',
        dateTime: DateTime.now(),
        cashierName: printData['cashierName'] ?? 'Kasir',
        items: items,
        subtotal: (printData['subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (printData['tax'] as num?)?.toDouble() ?? 0.0,
        discount: (printData['discount'] as num?)?.toDouble() ?? 0.0,
        total: (printData['total'] as num?)?.toDouble() ?? 0.0,
        cash: (printData['cash'] as num?)?.toDouble() ?? 0.0,
        change: (printData['change'] as num?)?.toDouble() ?? 0.0,
        notes: printData['notes'],
      );

      // Print receipt
      final success = await controller.printReceipt(receiptData);
      
      if (success) {
        // Show dialog sukses dengan opsi kembali
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Berhasil!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Struk berhasil dicetak',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'No. Struk: ${printData['receiptNumber']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Back to previous page
                },
                child: Text(
                  'Kembali',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back(); // Close dialog
                  // Print lagi
                  await _printReceiptFromData(printData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                ),
                child: Text(
                  'Cetak Ulang',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
