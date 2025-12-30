import 'package:chiroku_cafe/utils/enums/user_enum.dart';

class SignUpResponse {
   final String userId;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  SignUpResponse({
    required this.userId,
    required this.email,
    this.role = UserRole.cashier,
    this.fullName,
    this.avatarUrl,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      userId: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] ?? UserRole.cashier,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}