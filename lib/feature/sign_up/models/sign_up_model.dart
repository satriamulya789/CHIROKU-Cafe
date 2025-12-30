class SignUpModel {
  final String fullName;
  final String email;
  final String password;
  final String role; 

  SignUpModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'cashier',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      };
}