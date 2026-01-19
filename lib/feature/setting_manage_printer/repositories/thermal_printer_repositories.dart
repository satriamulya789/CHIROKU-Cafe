import '../models/thermal_printer_model.dart';
import '../services/thermal_printer_service.dart';

class ThermalPrinterRepository {
  final ThermalPrinterService _service = ThermalPrinterService();

  Stream<PrinterConnectionStatus> get connectionStatusStream =>
      _service.connectionStatusStream;

  Future<bool> isBluetoothAvailable() async {
    try {
      return await _service.isBluetoothAvailable();
    } catch (e) {
      throw PrinterException(
        message: 'Failed to check Bluetooth availability: $e',
        code: 'BLUETOOTH_CHECK_ERROR',
      );
    }
  }

  Future<bool> requestBluetoothPermissions() async {
    try {
      return await _service.requestBluetoothPermissions();
    } catch (e) {
      throw PrinterException(
        message: 'Failed to request Bluetooth permissions: $e',
        code: 'PERMISSION_ERROR',
      );
    }
  }

  Future<List<BluetoothPrinterModel>> scanDevices() async {
    try {
      return await _service.scanDevices();
    } catch (e) {
      throw PrinterException(
        message: 'Failed to scan devices: $e',
        code: 'SCAN_ERROR',
      );
    }
  }

  Future<bool> connectToPrinter(BluetoothPrinterModel printer) async {
    try {
      return await _service.connectToPrinter(printer);
    } catch (e) {
      throw PrinterException(
        message: 'Failed to connect to printer: $e',
        code: 'CONNECTION_ERROR',
      );
    }
  }

  Future<bool> disconnectPrinter() async {
    try {
      return await _service.disconnectPrinter();
    } catch (e) {
      throw PrinterException(
        message: 'Failed to disconnect printer: $e',
        code: 'DISCONNECT_ERROR',
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      return await _service.isConnected();
    } catch (e) {
      return false;
    }
  }

  Future<bool> printReceipt(ReceiptDataModel receiptData) async {
    try {
      return await _service.printReceipt(receiptData);
    } catch (e) {
      throw PrinterException(
        message: 'Failed to print receipt: $e',
        code: 'PRINT_ERROR',
      );
    }
  }

  BluetoothPrinterModel? get connectedPrinter => _service.connectedPrinter;
  PrinterConnectionStatus get currentStatus => _service.currentStatus;
}