class TableModel {
  final int id;
  final String tableName;
  final int capacity;
  final String status; // 'available', 'reserved'
  final DateTime createdAt;

  TableModel({
    required this.id,
    required this.tableName,
    required this.capacity,
    required this.status,
    required this.createdAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tableName: json['table_name'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

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

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isReserved => status.toLowerCase() == 'reserved';
}
