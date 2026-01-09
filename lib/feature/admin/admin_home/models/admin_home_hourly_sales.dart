class HourlySalesData {
  final String hour;
  final int sales;
  final int orderCount;

  HourlySalesData({
    required this.hour,
    required this.sales,
    required this.orderCount,
  });

  factory HourlySalesData.fromJson(Map<String, dynamic> json) {
    return HourlySalesData(
      hour: json['hour'] ?? '',
      sales: json['sales'] ?? 0,
      orderCount: json['order_count'] ?? 0,
    );
  }
}
