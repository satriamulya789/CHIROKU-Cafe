class CashierUserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashierUserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashierUserProfileModel.fromJson(Map<String, dynamic> json) {
    return CashierUserProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'cashier',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CashierUserProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashierUserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
