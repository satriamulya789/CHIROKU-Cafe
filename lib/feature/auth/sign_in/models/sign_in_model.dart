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
