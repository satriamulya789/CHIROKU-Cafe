class TableModel {
  final int? id;
  final String tableName;
  final int capacity;
  final String status;
  final DateTime? createdAt;

  TableModel({
    this.id,
    required this.tableName,
    this.capacity = 1,
    this.status = 'available',
    this.createdAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as int?,
      tableName: json['table_name'] as String,
      capacity: json['capacity'] as int? ?? 1,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'table_name': tableName,
      'capacity': capacity,
      'status': status,
    };
  }
}