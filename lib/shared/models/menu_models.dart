class MenuModel {
  final int id;
  final int? categoryId;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? categoryName;

  MenuModel({
    required this.id,
    this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  /// Factory constructor untuk parsing dari JSON (Supabase response)
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: _parseInt(json['id']),
      categoryId: json['category_id'] != null 
          ? _parseInt(json['category_id']) 
          : null,
      name: json['name'] as String? ?? '',
      price: _parseDouble(json['price']),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      categoryName: json['categories']?['name'] as String?,
    );
  }

  /// Parse integer dengan aman
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse double dengan aman
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert ke JSON untuk insert/update ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert ke JSON untuk insert (tanpa id dan timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  /// Convert ke JSON untuk update (tanpa id dan created_at)
  Map<String, dynamic> toUpdateJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Copy with method untuk membuat instance baru dengan perubahan
  MenuModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
  }) {
    return MenuModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  /// Get category display name (capitalize first letter)
  String get categoryDisplayName {
    if (categoryName == null) return 'Uncategorized';
    return categoryName!.substring(0, 1).toUpperCase() + 
           categoryName!.substring(1).toLowerCase();
  }

  /// Check if menu is food
  bool get isFood => categoryName?.toLowerCase() == 'food';

  /// Check if menu is beverage
  bool get isBeverage => categoryName?.toLowerCase() == 'beverage';

  @override
  String toString() {
    return 'MenuModel(id: $id, name: $name, price: $price, category: $categoryName, available: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}