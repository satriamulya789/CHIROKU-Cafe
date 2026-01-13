class TableModel {
  final int id;
  final String tableName;
  final int capacity;
  final String status;
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
      id: json['id'] as int,
      tableName: json['table_name'] as String,
      capacity: json['capacity'] as int? ?? 1,
      status: json['status'] as String? ?? 'available',
      createdAt: DateTime.parse(json['created_at'] as String),
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

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isReserved => status.toLowerCase() == 'reserved';
}