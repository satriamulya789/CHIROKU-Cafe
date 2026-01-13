class ReportAdminStat {
  final int totalOrders;
  final double totalRevenue;
  final double avgRevenue;
  final int itemsSold;

  ReportAdminStat({
    required this.totalOrders,
    required this.totalRevenue,
    required this.avgRevenue,
    required this.itemsSold,
  });

  factory ReportAdminStat.fromJson(Map<String, dynamic> json) {
    return ReportAdminStat(
      totalOrders: json['total_orders'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgRevenue: (json['avg_revenue'] as num).toDouble(),
      itemsSold: json['items_sold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'avg_revenue': avgRevenue,
      'items_sold': itemsSold,
    };
  }
}

class ReportProductStat {
  final int menuId;
  final String name;
  final double price;
  final int totalQty;
  final double totalRevenue;

  ReportProductStat({
    required this.menuId,
    required this.name,
    required this.price,
    required this.totalQty,
    required this.totalRevenue,
  });

  factory ReportProductStat.fromJson(Map<String, dynamic> json) {
    return ReportProductStat(
      menuId: json['menu_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      totalQty: json['total_qty'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'name': name,
      'price': price,
      'total_qty': totalQty,
      'total_revenue': totalRevenue,
    };
  }
}