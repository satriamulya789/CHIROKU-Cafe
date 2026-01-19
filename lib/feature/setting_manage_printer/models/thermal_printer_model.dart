class BluetoothPrinterModel {
  final String name;
  final String macAddress;
  final int? type;
  final bool connected;

  BluetoothPrinterModel({
    required this.name,
    required this.macAddress,
    this.type,
    this.connected = false,
  });

  factory BluetoothPrinterModel.fromMap(Map<String, dynamic> map) {
    return BluetoothPrinterModel(
      name: map['name'] ?? '',
      macAddress: map['macAddress'] ?? '',
      type: map['type'],
      connected: map['connected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'macAddress': macAddress,
      'type': type,
      'connected': connected,
    };
  }

  BluetoothPrinterModel copyWith({
    String? name,
    String? macAddress,
    int? type,
    bool? connected,
  }) {
    return BluetoothPrinterModel(
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      type: type ?? this.type,
      connected: connected ?? this.connected,
    );
  }

  @override
  String toString() {
    return 'BluetoothPrinterModel(name: $name, macAddress: $macAddress, type: $type, connected: $connected)';
  }
}

enum PrinterConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ReceiptItemModel {
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  ReceiptItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory ReceiptItemModel.fromMap(Map<String, dynamic> map) {
    return ReceiptItemModel(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class ReceiptDataModel {
  final String receiptNumber;
  final DateTime dateTime;
  final String cashierName;
  final List<ReceiptItemModel> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double cash;
  final double change;
  final String? notes;

  ReceiptDataModel({
    required this.receiptNumber,
    required this.dateTime,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.cash,
    required this.change,
    this.notes,
  });

  factory ReceiptDataModel.fromMap(Map<String, dynamic> map) {
    return ReceiptDataModel(
      receiptNumber: map['receiptNumber'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      cashierName: map['cashierName'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => ReceiptItemModel.fromMap(item))
          .toList(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      cash: (map['cash'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiptNumber': receiptNumber,
      'dateTime': dateTime.toIso8601String(),
      'cashierName': cashierName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'cash': cash,
      'change': change,
      'notes': notes,
    };
  }
}

class PrinterException implements Exception {
  final String message;
  final String? code;
  final dynamic stackTrace;

  PrinterException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'PrinterException(message: $message, code: $code)';
  }
}