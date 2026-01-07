import 'package:chiroku_cafe/utils/enums/user_enum.dart';

class SignInModel {
  final String email;
  final String password;
  final String role;

  const SignInModel({
    required this.email,
    required this.password,
    this.role = 'cashier',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role,
  };
}

class SignInResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;

  SignInResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.cashier;
    final roleString = role.toString().toLowerCase();
    if (roleString == 'admin') return UserRole.admin;
    return UserRole.cashier;
  }
}
