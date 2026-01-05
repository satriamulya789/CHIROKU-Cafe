class ForgotPasswordModel {
  final String email;
  final String message;
  final bool success;

  ForgotPasswordModel({
    required this.email,
    required this.message,
    required this.success,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'success': success,
    };
  }
}