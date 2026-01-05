class ResetPasswordModel {
  final String email;
  final String newPassword;
  final String confirmPassword;
  final String message;
  final bool success;

  ResetPasswordModel({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
    required this.message,
    required this.success,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      email: json['email'] ?? '',
      newPassword: json['newPassword'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'message': message,
      'success': success,
    };
  }
}