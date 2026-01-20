import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_category_model.dart';

class MenuModel {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryMenuModel? category;

  MenuModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    try {
      return MenuModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        isAvailable: json['is_available'] as bool? ?? true,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        category: json['categories'] != null
            ? CategoryMenuModel.fromJson(
                json['categories'] as Map<String, dynamic>,
              )
            : null,
      );
    } catch (e) {
      print('❌ Error parsing MenuModel: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }
}
