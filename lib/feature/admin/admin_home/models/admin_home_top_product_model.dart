class TopProductData {
  final String name;
  final int quantity;
  final int revenue;

  TopProductData({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  factory TopProductData.fromJson(Map<String, dynamic> json) {
    return TopProductData(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      revenue: json['revenue'] ?? 0,
    );
  }
}