class CheckoutModel {
  final String? customerName;
  final int? tableId;
  final String? tableName;
  final String paymentMethod; // 'cash', 'qris', 'card'
  final double cashReceived; // For cash payment
  final double changeAmount; // For cash payment
  final double subtotal;
  final double serviceFee;
  final double tax;
  final double discountAmount;
  final int? discountId;
  final String? discountName;
  final double total;
  final String? note;

  CheckoutModel({
    this.customerName,
    this.tableId,
    this.tableName,
    required this.paymentMethod,
    this.cashReceived = 0.0,
    this.changeAmount = 0.0,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    this.discountAmount = 0.0,
    this.discountId,
    this.discountName,
    required this.total,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'table_id': tableId,
      'table_name': tableName,
      'payment_method': paymentMethod,
      'cash_received': cashReceived,
      'change_amount': changeAmount,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'tax': tax,
      'discount_amount': discountAmount,
      'discount_id': discountId,
      'discount_name': discountName,
      'total': total,
      'note': note,
    };
  }

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      customerName: json['customer_name'] as String?,
      tableId: (json['table_id'] as num?)?.toInt(),
      tableName: json['table_name'] as String?,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      cashReceived: (json['cash_received'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      discountId: (json['discount_id'] as num?)?.toInt(),
      discountName: json['discount_name'] as String?,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
    );
  }

  CheckoutModel copyWith({
    String? customerName,
    int? tableId,
    String? tableName,
    String? paymentMethod,
    double? cashReceived,
    double? changeAmount,
    double? subtotal,
    double? serviceFee,
    double? tax,
    double? discountAmount,
    int? discountId,
    String? discountName,
    double? total,
    String? note,
  }) {
    return CheckoutModel(
      customerName: customerName ?? this.customerName,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      tax: tax ?? this.tax,
      discountAmount: discountAmount ?? this.discountAmount,
      discountId: discountId ?? this.discountId,
      discountName: discountName ?? this.discountName,
      total: total ?? this.total,
      note: note ?? this.note,
    );
  }
}
