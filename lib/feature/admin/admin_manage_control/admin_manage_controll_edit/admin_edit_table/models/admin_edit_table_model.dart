import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:drift/drift.dart' as drift;

class TableModel {
  final int? id;
  final String tableName;
  final int capacity;
  final String status;
  final DateTime? createdAt;

  // Offline tracking fields
  final bool needsSync;
  final bool isLocalOnly;
  final String? pendingOperation;
  final DateTime? syncedAt;

  TableModel({
    this.id,
    required this.tableName,
    this.capacity = 1,
    this.status = 'available',
    this.createdAt,
    this.needsSync = false,
    this.isLocalOnly = false,
    this.pendingOperation,
    this.syncedAt,
  });

  // From Supabase JSON
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as int?,
      tableName: json['table_name'] as String,
      capacity: json['capacity'] as int? ?? 1,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // From Drift local database
  factory TableModel.fromDrift(TablesLocal table) {
    return TableModel(
      id: table.id,
      tableName: table.name,
      capacity: table.capacity,
      status: table.status,
      createdAt: table.createdAt,
      needsSync: table.needsSync,
      isLocalOnly: table.isLocalOnly,
      pendingOperation: table.pendingOperation,
      syncedAt: table.syncedAt,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
    };
  }

  // To Drift companion for insert/update
  TablesLocalTableCompanion toDrift() {
    return TablesLocalTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      name: drift.Value(tableName),
      capacity: drift.Value(capacity),
      status: drift.Value(status),
      createdAt: createdAt != null
          ? drift.Value(createdAt!)
          : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
      needsSync: drift.Value(needsSync),
      isLocalOnly: drift.Value(isLocalOnly),
      pendingOperation: pendingOperation != null
          ? drift.Value(pendingOperation)
          : const drift.Value.absent(),
      syncedAt: syncedAt != null
          ? drift.Value(syncedAt)
          : const drift.Value.absent(),
    );
  }

  TableModel copyWith({
    int? id,
    String? tableName,
    int? capacity,
    String? status,
    DateTime? createdAt,
    bool? needsSync,
    bool? isLocalOnly,
    String? pendingOperation,
    DateTime? syncedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      needsSync: needsSync ?? this.needsSync,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      pendingOperation: pendingOperation ?? this.pendingOperation,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
