class OrderModel {
  final int id;
  final String? userId;
  final int? tableId;
  final String orderStatus;
  final double subtotal;
  final double serviceFee;
  final double tax;
  final double discount;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? tableName;
  final String? tableStatus;
  final String? cashierName;
  final String? customerName;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    this.userId,
    this.tableId,
    required this.orderStatus,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.createdAt,
    this.updatedAt,
    this.tableName,
    this.tableStatus,
    this.cashierName,
    this.customerName,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']),
      userId: json['user_id'] as String?,
      tableId: json['table_id'] != null ? _parseInt(json['table_id']) : null,
      orderStatus: json['order_status'] as String? ?? 'pending',
      subtotal: _parseDouble(json['subtotal']),
      serviceFee: _parseDouble(json['service_fee']),
      tax: _parseDouble(json['tax']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      tableName: json['tables']?['table_name'] as String?,
      tableStatus: json['tables']?['status'] as String?,
      cashierName: json['users']?['full_name'] as String?,
      customerName: json['customer_name'] as String?,
      items: json['order_items'] != null
          ? (json['order_items'] as List)
                .map((item) => OrderItemModel.fromJson(item))
                .toList()
          : null,
    );
  }

    // Optional table status (available, occupied, reserved)
    String? get tableStatusOrNull => tableStatus;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'table_id': tableId,
      'order_status': orderStatus,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'table_id': tableId,
      'order_status': orderStatus,
      'service_fee': serviceFee,
      'tax': tax,
      'discount': discount,
    };
  }

  // Status helpers
  bool get isPending => orderStatus == 'pending';
  bool get isPaid => orderStatus == 'paid';
  bool get isCompleted => orderStatus == 'completed';
  bool get isVoid => orderStatus == 'void';
  bool get isCancelled => orderStatus == 'cancelled';

  String get statusDisplayText {
    switch (orderStatus) {
      case 'pending':
        return 'Menunggu';
      case 'paid':
        return 'Dibayar';
      case 'completed':
        return 'Selesai';
      case 'void':
        return 'Batal';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return orderStatus;
    }
  }
}

class OrderItemModel {
  final int id;
  final int orderId;
  final int menuId;
  final int qty;
  final double price;
  final double subtotal;
  final String? menuName;
  final String? menuImage;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.menuName,
    this.menuImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['order_id']),
      menuId: _parseInt(json['menu_id']),
      qty: _parseInt(json['qty']),
      price: _parseDouble(json['price']),
      subtotal: _parseDouble(json['subtotal']),
      menuName: json['menu']?['name'] as String?,
      menuImage: json['menu']?['image_url'] as String?,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {'order_id': orderId, 'menu_id': menuId, 'qty': qty, 'price': price};
  }
}

class PaymentModel {
  final int id;
  final int orderId;
  final String paymentMethod;
  final double amount;
  final DateTime paidAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['order_id']),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      amount: _parseDouble(json['amount']),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
    };
  }

  String get paymentMethodDisplayText {
    switch (paymentMethod) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'card':
        return 'Kartu';
      default:
        return paymentMethod;
    }
  }
}
