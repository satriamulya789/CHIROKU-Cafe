import 'package:chiroku_cafe/feature/admin/admin_setting_manage_printer/models/thermal_printer_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_printer/repositories/thermal_printer_repositories.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ThermalPrinterController extends GetxController {
  final ThermalPrinterRepository _repository = ThermalPrinterRepository();
  final customSnackbar = CustomSnackbar();

  final RxList<BluetoothPrinterModel> availableDevices =
      <BluetoothPrinterModel>[].obs;
  final Rx<BluetoothPrinterModel?> selectedPrinter = Rx<BluetoothPrinterModel?>(
    null,
  );
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

  void _listenToConnectionStatus() {
    _repository.connectionStatusStream.listen((status) {
      connectionStatus.value = status;
    });
  }

  Future<void> checkBluetoothAvailability() async {
    try {
      final bool available = await _repository.isBluetoothAvailable();
      if (!available) {
        errorMessage.value = 'Bluetooth is not available or not enabled';
        customSnackbar.showErrorSnackbar('Please enable Bluetooth first');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final bool granted = await _repository.requestBluetoothPermissions();
      if (!granted) {
        errorMessage.value = 'Bluetooth permission denied';
        customSnackbar.showErrorSnackbar(
          'Permission Denied'
          'App requires Bluetooth permission to print',
        );
      }
      return granted;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> scanForPrinters() async {
    try {
      isScanning.value = true;
      errorMessage.value = '';

      final bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        isScanning.value = false;
        return;
      }

      final List<BluetoothPrinterModel> devices = await _repository
          .scanDevices();
      availableDevices.value = devices;

      if (devices.isEmpty) {
        customSnackbar.showSuccessSnackbar(
          'Scan Complete'
          'No printers found. Make sure the printer is paired in Bluetooth settings.',
        );
      } else {
        customSnackbar.showSuccessSnackbar(
          'Scan Complete'
          'Found ${devices.length} printer(s)',
        );
      }
    } on PrinterException catch (e) {
      errorMessage.value = e.message;
      customSnackbar.showErrorSnackbar( e.message);
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar(
        'Failed to scan printers: ${e.toString()}',
      );
    } finally {
      isScanning.value = false;
    }
  }

  Future<bool> connectToPrinter(BluetoothPrinterModel printer) async {
    try {
      errorMessage.value = '';

      final bool connected = await _repository.connectToPrinter(printer);

      if (connected) {
        selectedPrinter.value = printer;
        customSnackbar.showSuccessSnackbar(
          'Connected to ${printer.name}',
        );
        return true;
      } else {
        errorMessage.value = 'Failed to connect to printer';
        customSnackbar.showErrorSnackbar(
          'Could not connect to ${printer.name}',
        );
        return false;
      }
    } on PrinterException catch (e) {
      errorMessage.value = e.message;
      customSnackbar.showErrorSnackbar(e.message);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar(
        'Failed to connect: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      final bool disconnected = await _repository.disconnectPrinter();
      if (disconnected) {
        selectedPrinter.value = null;
        customSnackbar.showErrorSnackbar(
          'Printer connection closed',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar(
        'Failed to disconnect: ${e.toString()}',
      );
    }
  }

  Future<bool> checkConnection() async {
    try {
      return await _repository.isConnected();
    } catch (e) {
      return false;
    }
  }

  Future<bool> printReceipt(ReceiptDataModel receiptData) async {
    try {
      isPrinting.value = true;
      errorMessage.value = '';

      final bool connected = await checkConnection();
      if (!connected) {
        customSnackbar.showErrorSnackbar(
          'Not Connected'
          'Printer is not connected. Please connect the printer first.',
        );
        return false;
      }

      final bool success = await _repository.printReceipt(receiptData);

      if (success) {
        customSnackbar.showSuccessSnackbar(
          'Success'
          'Receipt printed successfully',
        );
        return true;
      } else {
        errorMessage.value = 'Failed to print receipt';
        customSnackbar.showErrorSnackbar(
          'Failed'
          'Failed to print receipt',
        );
        return false;
      }
    } on PrinterException catch (e) {
      errorMessage.value = e.message;
      customSnackbar.showErrorSnackbar( e.message);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar(
        'Error'
        'Failed to print: ${e.toString()}',
      );
      return false;
    } finally {
      isPrinting.value = false;
    }
  }

  Future<void> testPrint() async {
    final testReceipt = ReceiptDataModel(
      receiptNumber: 'TEST-001',
      dateTime: DateTime.now(),
      cashierName: 'Test Cashier',
      items: [
        ReceiptItemModel(
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
}
