import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:drift/drift.dart' as drift;

class CategoryModel {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Offline tracking fields
  final bool needsSync;
  final bool isDeleted;
  final DateTime? syncedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.needsSync = false,
    this.isDeleted = false,
    this.syncedAt,
  });

  // From Supabase JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // From Drift local database
  factory CategoryModel.fromDrift(CategoryLocal category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      needsSync: category.needsSync,
      isDeleted: category.isDeleted,
      syncedAt: category.syncedAt,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // To Drift companion for insert/update
  CategoryLocalTableCompanion toDrift() {
    return CategoryLocalTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      name: drift.Value(name),
      createdAt: createdAt != null
          ? drift.Value(createdAt!)
          : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
      needsSync: drift.Value(needsSync),
      isDeleted: drift.Value(isDeleted),
      syncedAt: syncedAt != null
          ? drift.Value(syncedAt)
          : const drift.Value.absent(),
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
    bool? isDeleted,
    DateTime? syncedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
