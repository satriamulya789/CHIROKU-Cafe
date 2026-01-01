class SignUpResponse {
   final String userId;
  final String email;
  final String role;
  final String? fullName;
  final String? avatarUrl;
  SignUpResponse({
    required this.userId,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      userId: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] ?? 'cashier',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}