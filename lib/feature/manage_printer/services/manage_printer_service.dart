import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/manage_printer_model.dart';

class ManagePrinterService {
  static final ManagePrinterService _instance =
      ManagePrinterService._internal();
  factory ManagePrinterService() => _instance;
  ManagePrinterService._internal();

  final _connectionStatusController =
      StreamController<PrinterConnectionStatus>.broadcast();
  Stream<PrinterConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  PrinterConnectionStatus _currentStatus = PrinterConnectionStatus.disconnected;
  BluetoothPrinterModel? _connectedPrinter;

  BluetoothPrinterModel? get connectedPrinter => _connectedPrinter;
  PrinterConnectionStatus get currentStatus => _currentStatus;

  Future<bool> isBluetoothAvailable() async {
    try {
      final bool result = await PrintBluetoothThermal.bluetoothEnabled;
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestBluetoothPermissions() async {
    try {
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<BluetoothPrinterModel>> scanDevices() async {
    try {
      // PrintBluetoothThermal.pairedBluetooths returns paired devices
      // For all available (scanned), some plugins use a different method.
      // print_bluetooth_thermal primarily works with paired devices.
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;

      return devices.map((device) {
        return BluetoothPrinterModel(
          name: device.name,
          macAddress: device.macAdress,
          type: 1,
          connected: false,
        );
      }).toList();
    } catch (e) {
      throw PrinterException(
        message: 'Failed to scan devices: ${e.toString()}',
        code: 'SCAN_ERROR',
        stackTrace: e,
      );
    }
  }

  Future<bool> connectToPrinter(BluetoothPrinterModel printer) async {
    try {
      _connectionStatusController.add(PrinterConnectionStatus.connecting);

      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAddress,
      );

      if (result) {
        _connectedPrinter = printer.copyWith(connected: true);
        _currentStatus = PrinterConnectionStatus.connected;
        _connectionStatusController.add(PrinterConnectionStatus.connected);
      } else {
        _currentStatus = PrinterConnectionStatus.error;
        _connectionStatusController.add(PrinterConnectionStatus.error);
      }

      return result;
    } catch (e) {
      _currentStatus = PrinterConnectionStatus.error;
      _connectionStatusController.add(PrinterConnectionStatus.error);
      throw PrinterException(
        message: 'Failed to connect to printer: ${e.toString()}',
        code: 'CONNECTION_ERROR',
        stackTrace: e,
      );
    }
  }

  Future<bool> disconnectPrinter() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;

      if (result) {
        _connectedPrinter = null;
        _currentStatus = PrinterConnectionStatus.disconnected;
        _connectionStatusController.add(PrinterConnectionStatus.disconnected);
      }

      return result;
    } catch (e) {
      throw PrinterException(
        message: 'Failed to disconnect: ${e.toString()}',
        code: 'DISCONNECT_ERROR',
        stackTrace: e,
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      final bool result = await PrintBluetoothThermal.connectionStatus;
      if (!result) {
        _connectedPrinter = null;
        _currentStatus = PrinterConnectionStatus.disconnected;
        _connectionStatusController.add(PrinterConnectionStatus.disconnected);
      } else {
        _currentStatus = PrinterConnectionStatus.connected;
        _connectionStatusController.add(PrinterConnectionStatus.connected);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> printReceipt(ReceiptDataModel receiptData) async {
    try {
      final bool connected = await isConnected();
      if (!connected) {
        throw PrinterException(
          message: 'Printer not connected',
          code: 'NOT_CONNECTED',
        );
      }

      final List<int> bytes = await _generateReceiptBytes(receiptData);
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      throw PrinterException(
        message: 'Failed to print receipt: ${e.toString()}',
        code: 'PRINT_ERROR',
        stackTrace: e,
      );
    }
  }

  Future<List<int>> _generateReceiptBytes(ReceiptDataModel data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text(
      'CHIROKU CAFE',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Jl. Example No. 123',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Telp: 0123-4567-890',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'No: ${data.receiptNumber}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Cashier: ${data.cashierName}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Date: ${_formatDateTime(data.dateTime)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'Item                 Qty  Price',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.hr(ch: '-');

    for (var item in data.items) {
      bytes += generator.text(
        item.name,
        styles: const PosStyles(align: PosAlign.left),
      );
      final qtyPrice = '${item.quantity}x ${_formatCurrency(item.price)}';
      final subtotal = _formatCurrency(item.subtotal);
      final spaces = ' ' * (32 - qtyPrice.length - subtotal.length);
      bytes += generator.text(
        '$qtyPrice$spaces$subtotal',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'Subtotal:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: _formatCurrency(data.subtotal),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (data.tax > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Tax:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: _formatCurrency(data.tax),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (data.discount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${_formatCurrency(data.discount)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: _formatCurrency(data.total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'Cash:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: _formatCurrency(data.cash),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Change:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: _formatCurrency(data.change),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    if (data.notes != null && data.notes!.isNotEmpty) {
      bytes += generator.text(
        data.notes!,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();
    }

    bytes += generator.text(
      'Thank You',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Please Come Again!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
