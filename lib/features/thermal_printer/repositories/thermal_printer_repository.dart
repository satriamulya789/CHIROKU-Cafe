import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/printer_model.dart';

class ThermalPrinterRepository {
  // Singleton pattern
  static final ThermalPrinterRepository _instance =
      ThermalPrinterRepository._internal();
  factory ThermalPrinterRepository() => _instance;
  ThermalPrinterRepository._internal();

  // Stream controller untuk status koneksi
  final _connectionStatusController =
      StreamController<PrinterConnectionStatus>.broadcast();
  Stream<PrinterConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  PrinterConnectionStatus _currentStatus = PrinterConnectionStatus.disconnected;
  BluetoothPrinter? _connectedPrinter;

  /// Cek apakah bluetooth tersedia
  Future<bool> isBluetoothAvailable() async {
    try {
      final bool result = await PrintBluetoothThermal.bluetoothEnabled;
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Request izin bluetooth (Android 12+)
  Future<bool> requestBluetoothPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Permissions biasanya sudah ditangani oleh plugin
        // atau harus di-request lewat AndroidManifest.xml
        return true;
      }
      return true; // iOS tidak perlu request manual
    } catch (e) {
      return false;
    }
  }

  /// Scan perangkat bluetooth yang tersedia
  Future<List<BluetoothPrinter>> scanDevices() async {
    try {
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;

      return devices.map((device) {
        return BluetoothPrinter(
          name: device.name,
          macAddress: device.macAdress, // Note: typo in package is 'macAdress'
          type: 1, // Classic bluetooth
          connected: false,
        );
      }).toList();
    } catch (e) {
      throw PrinterError(
        message: 'Gagal memindai perangkat: ${e.toString()}',
        code: 'SCAN_ERROR',
        stackTrace: e,
      );
    }
  }

  /// Koneksi ke printer
  Future<bool> connectToPrinter(BluetoothPrinter printer) async {
    try {
      _connectionStatusController.add(PrinterConnectionStatus.connecting);

      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: printer.macAddress);

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
      throw PrinterError(
        message: 'Gagal menghubungkan ke printer: ${e.toString()}',
        code: 'CONNECTION_ERROR',
        stackTrace: e,
      );
    }
  }

  /// Disconnect dari printer
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
      throw PrinterError(
        message: 'Gagal memutus koneksi: ${e.toString()}',
        code: 'DISCONNECT_ERROR',
        stackTrace: e,
      );
    }
  }

  /// Cek status koneksi printer
  Future<bool> isConnected() async {
    try {
      final bool result = await PrintBluetoothThermal.connectionStatus;
      if (!result) {
        _connectedPrinter = null;
        _currentStatus = PrinterConnectionStatus.disconnected;
        _connectionStatusController.add(PrinterConnectionStatus.disconnected);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Cetak struk
  Future<bool> printReceipt(ReceiptData receiptData) async {
    try {
      // Cek koneksi
      final bool connected = await isConnected();
      if (!connected) {
        throw PrinterError(
          message: 'Printer tidak terhubung',
          code: 'NOT_CONNECTED',
        );
      }

      // Generate receipt bytes
      final List<int> bytes = await _generateReceiptBytes(receiptData);

      // Print
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      throw PrinterError(
        message: 'Gagal mencetak struk: ${e.toString()}',
        code: 'PRINT_ERROR',
        stackTrace: e,
      );
    }
  }

  /// Generate bytes untuk struk menggunakan ESC/POS commands
  Future<List<int>> _generateReceiptBytes(ReceiptData data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header - Logo/Nama Toko
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
      'Jl. Contoh No. 123',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Telp: 0123-4567-890',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Info Transaksi
    bytes += generator.text(
      'No: ${data.receiptNumber}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Kasir: ${data.cashierName}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Tanggal: ${_formatDateTime(data.dateTime)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.hr();

    // Items
    bytes += generator.text(
      'Item                 Qty  Harga',
      styles: const PosStyles(bold: true),
    );
    bytes += generator.hr(ch: '-');

    for (var item in data.items) {
      // Nama item
      bytes += generator.text(
        item.name,
        styles: const PosStyles(align: PosAlign.left),
      );
      // Qty dan Harga
      final qtyPrice = '${item.quantity}x ${_formatCurrency(item.price)}';
      final subtotal = _formatCurrency(item.subtotal);
      final spaces = ' ' * (32 - qtyPrice.length - subtotal.length);
      bytes += generator.text(
        '$qtyPrice$spaces$subtotal',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    bytes += generator.hr();

    // Subtotal, Pajak, Diskon
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
          text: 'Pajak:',
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
          text: 'Diskon:',
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

    // Total
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

    // Pembayaran
    bytes += generator.row([
      PosColumn(
        text: 'Tunai:',
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
        text: 'Kembali:',
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

    // Notes
    if (data.notes != null && data.notes!.isNotEmpty) {
      bytes += generator.text(
        data.notes!,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();
    }

    // Footer
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Selamat Menikmati!',
      styles: const PosStyles(align: PosAlign.center),
    );

    // Feed paper
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Format tanggal dan waktu
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  /// Format mata uang
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // Getter
  BluetoothPrinter? get connectedPrinter => _connectedPrinter;
  PrinterConnectionStatus get currentStatus => _currentStatus;

  // Dispose
  void dispose() {
    _connectionStatusController.close();
  }
}

// Extension helper
extension BluetoothPrinterExtension on BluetoothPrinter {
  BluetoothPrinter copyWith({
    String? name,
    String? macAddress,
    int? type,
    bool? connected,
  }) {
    return BluetoothPrinter(
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      type: type ?? this.type,
      connected: connected ?? this.connected,
    );
  }
}
