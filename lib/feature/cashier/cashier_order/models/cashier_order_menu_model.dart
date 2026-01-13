class MenuModel {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final int stock;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.stock,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      stock: json['stock'] as int? ?? 0,
      categoryName: json['categories']?['name'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get categoryDisplayName => categoryName.toUpperCase();
  bool get inStock => stock > 0;
}



