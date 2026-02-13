import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:drift/drift.dart' as drift;

class MenuModel {
  final int? id;
  final int categoryId;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? localImagePath; // For offline image storage
  final bool isAvailable;
  final int stock;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CategoryMenuModel? category;

  // Offline tracking fields
  final bool needsSync;
  final bool isDeleted;
  final bool isLocalOnly;
  final String? pendingOperation; // CREATE, UPDATE, DELETE
  final DateTime? syncedAt;

  MenuModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.localImagePath,
    this.isAvailable = true,
    this.stock = 0,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.needsSync = false,
    this.isDeleted = false,
    this.isLocalOnly = false,
    this.pendingOperation,
    this.syncedAt,
  });

  // From Supabase JSON
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int?,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      stock: json['stock'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      category: json['categories'] != null
          ? CategoryMenuModel.fromJson(
              json['categories'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  // From Drift local database
  factory MenuModel.fromDrift(MenuLocal menu) {
    return MenuModel(
      id: menu.id,
      categoryId: menu.categoryId,
      name: menu.name,
      price: menu.price,
      description: menu.description,
      imageUrl: menu.imageUrl,
      localImagePath: menu.localImagePath,
      isAvailable: menu.isAvailable,
      stock: menu.stock,
      createdAt: menu.createdAt,
      updatedAt: menu.updatedAt,
      needsSync: menu.needsSync,
      isDeleted: menu.isDeleted,
      isLocalOnly: menu.isLocalOnly,
      pendingOperation: menu.pendingOperation,
      syncedAt: menu.syncedAt,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'stock': stock,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // To Drift companion for insert/update
  MenuLocalTableCompanion toDrift() {
    return MenuLocalTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      categoryId: drift.Value(categoryId),
      name: drift.Value(name),
      price: drift.Value(price),
      description: drift.Value(description),
      imageUrl: drift.Value(imageUrl),
      localImagePath: drift.Value(localImagePath),
      isAvailable: drift.Value(isAvailable),
      stock: drift.Value(stock),
      createdAt: createdAt != null
          ? drift.Value(createdAt!)
          : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
      needsSync: drift.Value(needsSync),
      isDeleted: drift.Value(isDeleted),
      isLocalOnly: drift.Value(isLocalOnly),
      pendingOperation: drift.Value(pendingOperation),
      syncedAt: syncedAt != null
          ? drift.Value(syncedAt)
          : const drift.Value.absent(),
    );
  }

  MenuModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? localImagePath,
    bool? isAvailable,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryMenuModel? category,
    bool? needsSync,
    bool? isDeleted,
    bool? isLocalOnly,
    String? pendingOperation,
    DateTime? syncedAt,
  }) {
    return MenuModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      pendingOperation: pendingOperation ?? this.pendingOperation,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

class CategoryMenuModel {
  final int id;
  final String name;

  CategoryMenuModel({required this.id, required this.name});

  factory CategoryMenuModel.fromJson(Map<String, dynamic> json) {
    return CategoryMenuModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
