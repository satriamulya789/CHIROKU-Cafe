// import 'package:blue_thermal_printer/blue_thermal_printer.dart';

// class PrinterService {
//   final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

//   /// Get available bluetooth devices
//   Future<List<BluetoothDevice>> getAvailableDevices() async {
//     try {
//       final devices = await _bluetooth.getBondedDevices();
//       return devices;
//     } catch (e) {
//       throw Exception('Failed to get devices: $e');
//     }
//   }

//   /// Connect to printer
//   Future<bool> connectToPrinter(BluetoothDevice device) async {
//     try {
//       await _bluetooth.connect(device);
//       final isConnected = await _bluetooth.isConnected ?? false;
//       return isConnected;
//     } catch (e) {
//       throw Exception('Failed to connect: $e');
//     }
//   }

//   /// Disconnect printer
//   Future<void> disconnect() async {
//     try {
//       await _bluetooth.disconnect();
//     } catch (e) {
//       throw Exception('Failed to disconnect: $e');
//     }
//   }

//   /// Check if printer is connected
//   Future<bool> isConnected() async {
//     try {
//       return await _bluetooth.isConnected ?? false;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Test print
//   Future<void> testPrint() async {
//     try {
//       final isConnected = await this.isConnected();
//       if (!isConnected) {
//         throw Exception('Printer not connected');
//       }

//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('CHIROKU CAFE', 2, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('Test Print', 1, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('Printer is working!', 0, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('Date: ${DateTime.now()}', 0, 0);
//       _bluetooth.printNewLine();
//       _bluetooth.printNewLine();
//       _bluetooth.paperCut();
//     } catch (e) {
//       throw Exception('Failed to test print: $e');
//     }
//   }

//   /// Print receipt (example for order)
//   Future<void> printReceipt({
//     required String orderNumber,
//     required String customerName,
//     required List<Map<String, dynamic>> items,
//     required double subtotal,
//     required double tax,
//     required double total,
//   }) async {
//     try {
//       final isConnected = await this.isConnected();
//       if (!isConnected) {
//         throw Exception('Printer not connected');
//       }

//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('CHIROKU CAFE', 2, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('Order #$orderNumber', 1, 1);
//       _bluetooth.printCustom('Customer: $customerName', 0, 0);
//       _bluetooth.printCustom('Date: ${DateTime.now()}', 0, 0);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('--------------------------------', 0, 0);
      
//       for (var item in items) {
//         _bluetooth.printCustom(
//           '${item['name']}',
//           0,
//           0,
//         );
//         _bluetooth.printCustom(
//           '  ${item['qty']} x Rp ${item['price']} = Rp ${item['total']}',
//           0,
//           0,
//         );
//       }
      
//       _bluetooth.printCustom('--------------------------------', 0, 0);
//       _bluetooth.printCustom('Subtotal: Rp $subtotal', 0, 2);
//       _bluetooth.printCustom('Tax: Rp $tax', 0, 2);
//       _bluetooth.printCustom('Total: Rp $total', 1, 2);
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom('Thank you!', 0, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printNewLine();
//       _bluetooth.paperCut();
//     } catch (e) {
//       throw Exception('Failed to print receipt: $e');
//     }
//   }
// }