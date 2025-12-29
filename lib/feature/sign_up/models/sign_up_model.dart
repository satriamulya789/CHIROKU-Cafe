import 'package:chiroku_cafe/utils/enums/user_enum.dart';

class SignUpModel {
  final String fullName;
  final String email;
  final String password;
  final UserRole role; 

  SignUpModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.role = UserRole.cashier,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      };
}