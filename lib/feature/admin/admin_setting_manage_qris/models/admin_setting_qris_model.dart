class PaymentSettingModel {
  final int id;
  final String? qrisUrl;
  final DateTime updatedAt;

  PaymentSettingModel({
    required this.id,
    this.qrisUrl,
    required this.updatedAt,
  });

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      id: json['id'] as int,
      qrisUrl: json['qris_url'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qris_url': qrisUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentSettingModel copyWith({
    int? id,
    String? qrisUrl,
    DateTime? updatedAt,
  }) {
    return PaymentSettingModel(
      id: id ?? this.id,
      qrisUrl: qrisUrl ?? this.qrisUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}