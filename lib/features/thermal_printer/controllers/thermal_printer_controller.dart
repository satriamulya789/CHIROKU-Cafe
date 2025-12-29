import 'package:get/get.dart';
import '../models/printer_model.dart';
import '../repositories/thermal_printer_repository.dart';

class ThermalPrinterController extends GetxController {
  final ThermalPrinterRepository _repository = ThermalPrinterRepository();

  // Observable variables
  final RxList<BluetoothPrinter> availableDevices = <BluetoothPrinter>[].obs;
  final Rx<BluetoothPrinter?> selectedPrinter = Rx<BluetoothPrinter?>(null);
  final Rx<PrinterConnectionStatus> connectionStatus =
      PrinterConnectionStatus.disconnected.obs;
  final RxBool isScanning = false.obs;
  final RxBool isPrinting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToConnectionStatus();
    checkBluetoothAvailability();
  }

  /// Listen to connection status stream
  void _listenToConnectionStatus() {
    _repository.connectionStatusStream.listen((status) {
      connectionStatus.value = status;
    });
  }

  /// Check bluetooth availability
  Future<void> checkBluetoothAvailability() async {
    try {
      final bool available = await _repository.isBluetoothAvailable();
      if (!available) {
        errorMessage.value = 'Bluetooth tidak tersedia atau tidak diaktifkan';
        Get.snackbar(
          'Bluetooth',
          'Silakan aktifkan Bluetooth terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  /// Request bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      final bool granted = await _repository.requestBluetoothPermissions();
      if (!granted) {
        errorMessage.value = 'Izin Bluetooth ditolak';
        Get.snackbar(
          'Izin Ditolak',
          'Aplikasi memerlukan izin Bluetooth untuk mencetak',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return granted;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  /// Scan for available printers
  Future<void> scanForPrinters() async {
    try {
      isScanning.value = true;
      errorMessage.value = '';

      // Check permissions first
      final bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        isScanning.value = false;
        return;
      }

      // Scan devices
      final List<BluetoothPrinter> devices = await _repository.scanDevices();
      availableDevices.value = devices;

      if (devices.isEmpty) {
        Get.snackbar(
          'Pencarian Selesai',
          'Tidak ada printer yang ditemukan. Pastikan printer sudah dipasangkan di pengaturan Bluetooth.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } on PrinterError catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal memindai printer: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  /// Connect to selected printer
  Future<bool> connectToPrinter(BluetoothPrinter printer) async {
    try {
      errorMessage.value = '';

      final bool connected = await _repository.connectToPrinter(printer);

      if (connected) {
        selectedPrinter.value = printer;
        Get.snackbar(
          'Berhasil',
          'Terhubung ke ${printer.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        errorMessage.value = 'Gagal terhubung ke printer';
        Get.snackbar(
          'Gagal',
          'Tidak dapat terhubung ke ${printer.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on PrinterError catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal menghubungkan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Disconnect from printer
  Future<void> disconnectPrinter() async {
    try {
      final bool disconnected = await _repository.disconnectPrinter();
      if (disconnected) {
        selectedPrinter.value = null;
        Get.snackbar(
          'Terputus',
          'Koneksi printer terputus',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal memutus koneksi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Check if printer is connected
  Future<bool> checkConnection() async {
    try {
      return await _repository.isConnected();
    } catch (e) {
      return false;
    }
  }

  /// Print receipt
  Future<bool> printReceipt(ReceiptData receiptData) async {
    try {
      isPrinting.value = true;
      errorMessage.value = '';

      // Check connection first
      final bool connected = await checkConnection();
      if (!connected) {
        Get.snackbar(
          'Tidak Terhubung',
          'Printer tidak terhubung. Silakan hubungkan printer terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Print
      final bool success = await _repository.printReceipt(receiptData);

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Struk berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        errorMessage.value = 'Gagal mencetak struk';
        Get.snackbar(
          'Gagal',
          'Gagal mencetak struk',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on PrinterError catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal mencetak: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isPrinting.value = false;
    }
  }

  /// Test print - for testing printer connection
  Future<void> testPrint() async {
    final testReceipt = ReceiptData(
      receiptNumber: 'TEST-001',
      dateTime: DateTime.now(),
      cashierName: 'Test',
      items: [
        ReceiptItem(
          name: 'Test Item',
          quantity: 1,
          price: 10000,
          subtotal: 10000,
        ),
      ],
      subtotal: 10000,
      tax: 1000,
      discount: 0,
      total: 11000,
      cash: 20000,
      change: 9000,
      notes: 'Test Print',
    );

    await printReceipt(testReceipt);
  }

  @override
  void onClose() {
    _repository.dispose();
    super.onClose();
  }
}
