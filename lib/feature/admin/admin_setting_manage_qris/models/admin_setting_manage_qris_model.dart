class PaymentSettingsModel {
  final int id;
  final String? qrisUrl;
  final DateTime? updatedAt;

  PaymentSettingsModel({
    required this.id,
    this.qrisUrl,
    this.updatedAt,
  });

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingsModel(
      id: json['id'] ?? 1,
      qrisUrl: json['qris_url'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qris_url': qrisUrl,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PaymentSettingsModel copyWith({
    int? id,
    String? qrisUrl,
    DateTime? updatedAt,
  }) {
    return PaymentSettingsModel(
      id: id ?? this.id,
      qrisUrl: qrisUrl ?? this.qrisUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentSettingsModel(id: $id, qrisUrl: $qrisUrl, updatedAt: $updatedAt)';
  }
}