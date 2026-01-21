class ReceiptModel {
  final int orderId;
  final String orderNumber;
  final DateTime createdAt;
  final String? customerName;
  final String? tableName;
  final String cashierName;
  final List<ReceiptItemModel> items;
  final double subtotal;
  final double serviceFee;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final double? cashReceived;
  final double? changeAmount;
  final String? note;
  final String status;

  ReceiptModel({
    required this.orderId,
    required this.orderNumber,
    required this.createdAt,
    this.customerName,
    this.tableName,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.cashReceived,
    this.changeAmount,
    this.note,
    required this.status,
  });

  factory ReceiptModel.fromOrderData(Map<String, dynamic> orderData) {
    final orderItems = orderData['order_items'] as List? ?? [];

    return ReceiptModel(
      orderId: orderData['id'] as int,
      orderNumber: '#${orderData['id']}',
      createdAt:
          DateTime.tryParse(orderData['created_at'] ?? '') ?? DateTime.now(),
      customerName: orderData['customer_name'],
      tableName: orderData['tables']?['table_name'],
      cashierName: orderData['cashier_name'] ?? 'Cashier',
      items: orderItems.map((item) => ReceiptItemModel.fromJson(item)).toList(),
      subtotal: (orderData['subtotal'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (orderData['service_fee'] as num?)?.toDouble() ?? 0.0,
      tax: (orderData['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (orderData['discount_applied'] as num?)?.toDouble() ?? 0.0,
      total: (orderData['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: orderData['payment_method'] ?? 'cash',
      cashReceived: (orderData['cash_received'] as num?)?.toDouble(),
      changeAmount: (orderData['change_amount'] as num?)?.toDouble(),
      note: orderData['note'],
      status: orderData['order_status'] ?? 'pending',
    );
  }
}

class ReceiptItemModel {
  final String menuName;
  final int quantity;
  final double price;
  final double total;
  final String? note;

  ReceiptItemModel({
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.total,
    this.note,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'];
    final qty = (json['qty'] as num?)?.toInt() ?? 1;
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;

    return ReceiptItemModel(
      menuName: menu?['name'] ?? 'Unknown Item',
      quantity: qty,
      price: price,
      total: (json['total'] as num?)?.toDouble() ?? (price * qty),
      note: json['note'],
    );
  }
}
