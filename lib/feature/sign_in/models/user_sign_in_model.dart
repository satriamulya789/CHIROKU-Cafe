import 'package:chiroku_cafe/utils/enums/user_enum.dart';

class UserSignInModel {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  UserSignInModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserSignInModel.fromJson(Map<String, dynamic> json) {
    return UserSignInModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: UserRoleExt.fromString(json['role'] ?? 'cashier'),
    );
  }
}
