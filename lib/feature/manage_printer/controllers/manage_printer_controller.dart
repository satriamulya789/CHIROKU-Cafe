import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import '../models/manage_printer_model.dart';
import '../repositories/manage_printer_repository.dart';

class ManagePrinterController extends GetxController {
  final ManagePrinterRepository _repository = ManagePrinterRepository();
  final customSnackbar = CustomSnackbar();

  final RxList<BluetoothPrinterModel> availableDevices =
      <BluetoothPrinterModel>[].obs;
  final RxList<BluetoothPrinterModel> connectedDevices =
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
    scanForPrinters(); // Auto scan on init
  }

  void _listenToConnectionStatus() {
    _repository.connectionStatusStream.listen((status) {
      connectionStatus.value = status;
      if (status == PrinterConnectionStatus.disconnected) {
        selectedPrinter.value = null;
        _organizeDevices();
      }
    });
  }

  Future<void> checkBluetoothAvailability() async {
    try {
      final bool available = await _repository.isBluetoothAvailable();
      if (!available) {
        errorMessage.value = 'Bluetooth is not available or not enabled';
        // Only show snackbar if user is explicitly on this page
        if (Get.currentRoute.contains('manage-printer')) {
          customSnackbar.showErrorSnackbar('Please enable Bluetooth first');
        }
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
          'App requires Bluetooth permission to scan and print',
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

      // Update the devices and organize them
      _allDevices = devices;
      await _organizeDevices();

      if (devices.isEmpty) {
        customSnackbar.showSuccessSnackbar(
          'No printers found. Make sure the printer is turned on and paired.',
        );
      }
    } on PrinterException catch (e) {
      errorMessage.value = e.message;
      customSnackbar.showErrorSnackbar(e.message);
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar(
        'Failed to scan printers: ${e.toString()}',
      );
    } finally {
      isScanning.value = false;
    }
  }

  List<BluetoothPrinterModel> _allDevices = [];

  Future<void> _organizeDevices() async {
    final bool currentlyConnected = await _repository.isConnected();
    final BluetoothPrinterModel? activePrinter = _repository.connectedPrinter;

    final List<BluetoothPrinterModel> connected = [];
    final List<BluetoothPrinterModel> available = [];

    for (var device in _allDevices) {
      if (currentlyConnected &&
          activePrinter != null &&
          device.macAddress == activePrinter.macAddress) {
        connected.add(device.copyWith(connected: true));
        selectedPrinter.value = activePrinter;
      } else {
        available.add(device.copyWith(connected: false));
      }
    }

    connectedDevices.value = connected;
    availableDevices.value = available;
  }

  Future<bool> connectToPrinter(BluetoothPrinterModel printer) async {
    try {
      errorMessage.value = '';

      // If already connected to this printer, do nothing
      if (connectionStatus.value == PrinterConnectionStatus.connected &&
          selectedPrinter.value?.macAddress == printer.macAddress) {
        return true;
      }

      // If connected to another printer, disconnect first
      if (connectionStatus.value == PrinterConnectionStatus.connected) {
        await disconnectPrinter();
      }

      final bool success = await _repository.connectToPrinter(printer);

      if (success) {
        selectedPrinter.value = printer.copyWith(connected: true);
        await _organizeDevices();
        customSnackbar.showSuccessSnackbar('Connected to ${printer.name}');
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
      customSnackbar.showErrorSnackbar('Failed to connect: ${e.toString()}');
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      final bool disconnected = await _repository.disconnectPrinter();
      if (disconnected) {
        selectedPrinter.value = null;
        await _organizeDevices();
        customSnackbar.showSuccessSnackbar('Printer disconnected');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar('Failed to disconnect: ${e.toString()}');
    }
  }

  Future<bool> printReceipt(ReceiptDataModel receiptData) async {
    try {
      isPrinting.value = true;
      errorMessage.value = '';

      final bool connected = await _repository.isConnected();
      if (!connected) {
        customSnackbar.showErrorSnackbar(
          'Printer is not connected. Please connect the printer first.',
        );
        return false;
      }

      final bool success = await _repository.printReceipt(receiptData);

      if (success) {
        customSnackbar.showSuccessSnackbar('Receipt printed successfully');
        return true;
      } else {
        errorMessage.value = 'Failed to print receipt';
        customSnackbar.showErrorSnackbar('Failed to print receipt');
        return false;
      }
    } on PrinterException catch (e) {
      errorMessage.value = e.message;
      customSnackbar.showErrorSnackbar(e.message);
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      customSnackbar.showErrorSnackbar('Failed to print: ${e.toString()}');
      return false;
    } finally {
      isPrinting.value = false;
    }
  }

  Future<void> testPrint() async {
    final testReceipt = ReceiptDataModel(
      receiptNumber: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      cashierName: 'Admin',
      items: [
        ReceiptItemModel(
          name: 'Manual Test Item',
          quantity: 1,
          price: 15000,
          subtotal: 15000,
        ),
      ],
      subtotal: 15000,
      tax: 1500,
      discount: 0,
      total: 16500,
      cash: 20000,
      change: 3500,
      notes: 'Testing connection...',
    );

    await printReceipt(testReceipt);
  }
}
