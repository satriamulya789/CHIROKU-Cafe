class StockStatusModel {
  final int menuId;
  final String productName;
  final String category;
  final int currentStock;
  final String status;

  StockStatusModel({
    required this.menuId,
    required this.productName,
    required this.category,
    required this.currentStock,
    required this.status,
  });

  factory StockStatusModel.fromJson(Map<String, dynamic> json) {
    return StockStatusModel(
      menuId: json['menu_id'],
      productName: json['product_name'] ?? '',
      category: json['category'] ?? '',
      currentStock: json['current_stock'] ?? 0,
      status: json['status'] ?? 'ready',
    );
  }
}