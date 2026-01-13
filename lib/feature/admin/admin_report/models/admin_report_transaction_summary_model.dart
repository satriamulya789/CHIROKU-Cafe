class ReportTransaction {
  final int id;
  final double total;
  final String orderStatus;
  final DateTime createdAt;
  final int? tableId;
  final String? tableName;
  final String cashierId;
  final String cashierName;
  final String? customerName;
  final String? paymentMethod;

  ReportTransaction({
    required this.id,
    required this.total,
    required this.orderStatus,
    required this.createdAt,
    this.tableId,
    this.tableName,
    required this.cashierId,
    required this.cashierName,
    this.customerName,
    this.paymentMethod,
  });

  factory ReportTransaction.fromJson(Map<String, dynamic> json) {
    final table = json['tables'];
    final payments = json['payments'] as List?;
    
    return ReportTransaction(
      id: json['id'] as int,
      total: (json['total'] as num).toDouble(),
      orderStatus: json['order_status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      tableId: json['table_id'] as int?,
      tableName: table?['table_name'] as String?,
      cashierId: json['cashier_id'] as String,
      cashierName: json['cashier_name'] as String,
      customerName: json['customer_name'] as String?,
      paymentMethod: payments?.isNotEmpty == true 
          ? payments!.first['payment_method'] as String?
          : 'cash',
    );
  }
}