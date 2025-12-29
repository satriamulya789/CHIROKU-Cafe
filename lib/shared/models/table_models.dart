class TableModel {
  final int id;
  final String tableName;
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'
  final DateTime createdAt;

  TableModel({
    required this.id,
    required this.tableName,
    required this.capacity,
    required this.status,
    required this.createdAt,
  });

  /// Factory constructor untuk parsing dari JSON (Supabase response)
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: _parseInt(json['id']),
      tableName: json['table_name'] as String? ?? '',
      capacity: _parseInt(json['capacity'], defaultValue: 1),
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Parse integer dengan aman
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Convert ke JSON untuk response lengkap
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert ke JSON untuk insert (tanpa id dan created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
    };
  }

  /// Convert ke JSON untuk update (hanya field yang bisa diubah)
  Map<String, dynamic> toUpdateJson() {
    return {
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
    };
  }

  /// Update only status
  Map<String, dynamic> toStatusUpdateJson() {
    return {
      'status': status,
    };
  }

  /// Copy with method untuk membuat instance baru dengan perubahan
  TableModel copyWith({
    int? id,
    String? tableName,
    int? capacity,
    String? status,
    DateTime? createdAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==================== STATUS CHECKERS ====================

  /// Check if table is available
  bool get isAvailable => status.toLowerCase() == 'available';

  /// Check if table is occupied
  bool get isOccupied => status.toLowerCase() == 'occupied';

  /// Check if table is reserved
  bool get isReserved => status.toLowerCase() == 'reserved';

  /// Get status color for UI
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return 'green';
      case 'occupied':
        return 'orange';
      case 'reserved':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Get status display text (capitalized)
  String get statusDisplayText {
    return status.substring(0, 1).toUpperCase() + 
           status.substring(1).toLowerCase();
  }

  /// Get icon name for status
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'available':
        return 'check_circle';
      case 'occupied':
        return 'restaurant';
      case 'reserved':
        return 'bookmark';
      default:
        return 'table_restaurant';
    }
  }

  // ==================== VALIDATION ====================

  /// Validate table name
  bool get isTableNameValid => tableName.isNotEmpty;

  /// Validate capacity
  bool get isCapacityValid => capacity > 0;

  /// Validate status
  bool get isStatusValid {
    final validStatuses = ['available', 'occupied', 'reserved'];
    return validStatuses.contains(status.toLowerCase());
  }

  /// Check if all fields are valid
  bool get isValid => 
      isTableNameValid && 
      isCapacityValid && 
      isStatusValid;

  // ==================== UTILITY METHODS ====================

  /// Get capacity display text
  String get capacityText => '$capacity ${capacity > 1 ? 'people' : 'person'}';

  /// Check if table can be used for new order
  bool get canTakeOrder => isAvailable;

  /// Check if table can be released
  bool get canBeReleased => isOccupied || isReserved;

  @override
  String toString() {
    return 'TableModel(id: $id, name: $tableName, capacity: $capacity, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableModel && 
           other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== TABLE STATUS ENUM ====================

/// Enum untuk table status (optional, bisa digunakan untuk type safety)
enum TableStatus {
  available,
  occupied,
  reserved;

  /// Convert enum to string
  String toJson() => name;

  /// Convert string to enum
  static TableStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      default:
        return TableStatus.available;
    }
  }

  /// Get display text
  String get displayText {
    return name.substring(0, 1).toUpperCase() + 
           name.substring(1).toLowerCase();
  }
}