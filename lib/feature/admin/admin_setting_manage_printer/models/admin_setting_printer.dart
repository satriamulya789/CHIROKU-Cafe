class PrinterSettingModel {
  final String? printerName;
  final String? printerAddress;
  final bool isConnected;
  final PrinterType printerType;

  PrinterSettingModel({
    this.printerName,
    this.printerAddress,
    this.isConnected = false,
    this.printerType = PrinterType.bluetooth,
  });

  PrinterSettingModel copyWith({
    String? printerName,
    String? printerAddress,
    bool? isConnected,
    PrinterType? printerType,
  }) {
    return PrinterSettingModel(
      printerName: printerName ?? this.printerName,
      printerAddress: printerAddress ?? this.printerAddress,
      isConnected: isConnected ?? this.isConnected,
      printerType: printerType ?? this.printerType,
    );
  }
}

enum PrinterType {
  bluetooth,
  usb,
  network,
}