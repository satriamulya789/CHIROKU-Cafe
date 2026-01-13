class ReportCashierStat {
  final String cashierId;
  final String cashierName;
  final int totalOrders;
  final double totalRevenue;
  final int itemsSold;

  ReportCashierStat({
    required this.cashierId,
    required this.cashierName,
    required this.totalOrders,
    required this.totalRevenue,
    required this.itemsSold,
  });

  factory ReportCashierStat.fromJson(Map<String, dynamic> json) {
    return ReportCashierStat(
      cashierId: json['cashier_id'] as String,
      cashierName: json['cashier_name'] as String,
      totalOrders: json['total_orders'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      itemsSold: json['items_sold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'items_sold': itemsSold,
    };
  }
}