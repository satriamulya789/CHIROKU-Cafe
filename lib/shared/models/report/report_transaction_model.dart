class ReportTransaction {
  final int id;
  final double total;
  final String orderStatus;
  final DateTime createdAt;
  final String? tableName;
  final int? tableId;
  final String cashierName;
  final String? customerName;
  final String? paymentMethod;

  ReportTransaction({
    required this.id,
    required this.total,
    required this.orderStatus,
    required this.createdAt,
    this.tableName,
    this.tableId,
    required this.cashierName,
    this.customerName,
    this.paymentMethod,
  });

  factory ReportTransaction.fromJson(Map<String, dynamic> json) {
    return ReportTransaction(
      id: json['id'],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['order_status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      tableName: json['tables']?['table_name'] ?? json['tables']?['name'],
      tableId: json['table_id'],
      cashierName:
          json['cashier_name'] ?? json['profiles']?['full_name'] ?? 'Unknown',
      customerName: json['customer_name'],
      paymentMethod:
          json['payments'] != null && (json['payments'] as List).isNotEmpty
          ? json['payments'][0]['payment_method']
          : null,
    );
  }
}
