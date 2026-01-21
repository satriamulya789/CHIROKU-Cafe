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
      id: (json['id'] as num?)?.toInt() ?? 1,
      qrisUrl: json['qris_url'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qris_url': qrisUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasQrisUrl => qrisUrl != null && qrisUrl!.isNotEmpty;
}
