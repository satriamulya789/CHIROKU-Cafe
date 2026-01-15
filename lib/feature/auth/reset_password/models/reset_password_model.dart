class ResetPasswordModel {
  final String email;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordModel({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,

  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      email: json['email'] ?? '',
      newPassword: json['newPassword'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}