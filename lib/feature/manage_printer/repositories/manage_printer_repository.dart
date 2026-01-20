import '../models/manage_printer_model.dart';
import '../services/manage_printer_service.dart';

class ManagePrinterRepository {
  final ManagePrinterService _service = ManagePrinterService();

  Stream<PrinterConnectionStatus> get connectionStatusStream =>
      _service.connectionStatusStream;
  BluetoothPrinterModel? get connectedPrinter => _service.connectedPrinter;
  PrinterConnectionStatus get currentStatus => _service.currentStatus;

  Future<bool> isBluetoothAvailable() => _service.isBluetoothAvailable();
  Future<bool> requestBluetoothPermissions() =>
      _service.requestBluetoothPermissions();
  Future<List<BluetoothPrinterModel>> scanDevices() => _service.scanDevices();
  Stream<BluetoothPrinterModel> discoverDevices() => _service.discoverDevices();
  Future<bool> connectToPrinter(BluetoothPrinterModel printer) =>
      _service.connectToPrinter(printer);
  Future<bool> disconnectPrinter() => _service.disconnectPrinter();
  Future<bool> isConnected() => _service.isConnected();
  Future<bool> printReceipt(ReceiptDataModel receiptData) =>
      _service.printReceipt(receiptData);
}
