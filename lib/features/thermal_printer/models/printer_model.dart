/// Model untuk perangkat printer bluetooth
class BluetoothPrinter {
  final String name;
  final String macAddress;
  final int? type; // 1: classic, 2: low energy
  final bool connected;

  BluetoothPrinter({
    required this.name,
    required this.macAddress,
    this.type,
    this.connected = false,
  });

  factory BluetoothPrinter.fromMap(Map<String, dynamic> map) {
    return BluetoothPrinter(
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

  @override
  String toString() {
    return 'BluetoothPrinter(name: $name, macAddress: $macAddress, type: $type, connected: $connected)';
  }
}

/// Model untuk status koneksi printer
enum PrinterConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Model untuk item pada struk
class ReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
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

/// Model untuk data struk yang akan dicetak
class ReceiptData {
  final String receiptNumber;
  final DateTime dateTime;
  final String cashierName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double cash;
  final double change;
  final String? notes;

  ReceiptData({
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

  factory ReceiptData.fromMap(Map<String, dynamic> map) {
    return ReceiptData(
      receiptNumber: map['receiptNumber'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      cashierName: map['cashierName'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => ReceiptItem.fromMap(item))
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

/// Model untuk error printer
class PrinterError {
  final String message;
  final String? code;
  final dynamic stackTrace;

  PrinterError({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'PrinterError(message: $message, code: $code)';
  }
}
