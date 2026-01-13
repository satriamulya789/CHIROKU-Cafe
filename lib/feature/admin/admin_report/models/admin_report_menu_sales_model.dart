class MenuSales {
  final int menuId;
  final String name;
  final int totalQty;
  final double totalRevenue;

  MenuSales({
    required this.menuId,
    required this.name,
    required this.totalQty,
    required this.totalRevenue,
  });

   factory MenuSales.fromJson(Map<String, dynamic> json) {
    return MenuSales(
      menuId: json['menu_id'] as int,
      name: json['name'] as String,
      totalQty: json['total_qty'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'name': name,
      'total_qty': totalQty,
      'total_revenue': totalRevenue,
    };
  }

}

 