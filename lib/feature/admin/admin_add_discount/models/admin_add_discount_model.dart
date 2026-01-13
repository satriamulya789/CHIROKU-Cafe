class DiscountModel {
  final int? id;
  final String name;
  final String type; // 'fixed' or 'percent'
  final double value;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  DiscountModel({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  DiscountModel copyWith({
    int? id, // <-- perbaiki tipe id
    String? name,
    String? type,
    double? value,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
    id: json['id'] as int?,
    name: json['name'] as String,
    type: json['type'] as String,
    value: (json['value'] as num).toDouble(),
    isActive: json['is_active'] ?? true,
    startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
    endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'value': value,
    'is_active': isActive,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
  };
}