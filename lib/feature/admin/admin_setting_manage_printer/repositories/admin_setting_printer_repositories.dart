import 'package:shared_preferences/shared_preferences.dart';

class PrinterRepository {
  static const String _printerNameKey = 'printer_name';
  static const String _printerAddressKey = 'printer_address';
  static const String _printerTypeKey = 'printer_type';

  /// Save printer settings
  Future<void> savePrinterSettings({
    required String printerName,
    required String printerAddress,
    required String printerType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerNameKey, printerName);
    await prefs.setString(_printerAddressKey, printerAddress);
    await prefs.setString(_printerTypeKey, printerType);
  }

  /// Get printer settings
  Future<Map<String, String?>> getPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'printerName': prefs.getString(_printerNameKey),
      'printerAddress': prefs.getString(_printerAddressKey),
      'printerType': prefs.getString(_printerTypeKey) ?? 'bluetooth',
    };
  }

  /// Clear printer settings
  Future<void> clearPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerNameKey);
    await prefs.remove(_printerAddressKey);
    await prefs.remove(_printerTypeKey);
  }
}