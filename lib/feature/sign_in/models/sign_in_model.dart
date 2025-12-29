import 'package:chiroku_cafe/utils/enums/user_enum.dart';

class UserModel {
  final String email;
  final String password;
  final UserRole role;

  const UserModel({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toLoginJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: UserRoleExt.fromString(json['role'] ?? UserRole.cashier),
    );
  }

  
  bool get isAdmin => role == UserRole.admin;
  bool get isCashier => role == UserRole.cashier;
}
