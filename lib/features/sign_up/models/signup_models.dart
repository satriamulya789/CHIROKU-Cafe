class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String role; // (default cashier)

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = 'cashier',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      };

  @override
  String toString() => 'RegisterRequest(email: $email, fullName: $fullName)';
}

class RegisterResponse {
  final String userId;
  final String email;
  final String role;
  final String? fullName;
  final String? avatarUrl;

  RegisterResponse({
    required this.userId,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'cashier',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class RegisterError {
  final String message;
  final String? code;

  RegisterError({required this.message, this.code});

  factory RegisterError.fromException(dynamic e) {
    final s = e.toString().toLowerCase();
    if (s.contains('duplicate') || s.contains('unique')) {
      return RegisterError(message: 'Email sudah terdaftar', code: 'EMAIL_EXISTS');
    } else if (s.contains('invalid api key') || s.contains('401')) {
      return RegisterError(
          message:
              'Konfigurasi API tidak valid. Pastikan env supabase benar.',
          code: 'INVALID_API_KEY');
    } else if (s.contains('network')) {
      return RegisterError(message: 'Tidak ada koneksi internet', code: 'NETWORK');
    }
    return RegisterError(message: 'Pendaftaran gagal', code: 'UNKNOWN');
  }

  @override
  String toString() => 'RegisterError(message: $message, code: $code)';
}