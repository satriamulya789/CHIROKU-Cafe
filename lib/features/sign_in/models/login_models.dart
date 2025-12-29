/// Model untuk login request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email)';
  }
}

/// Model untuk login response
class LoginResponse {
  final String? accessToken;
  final String? refreshToken;
  final String userId;
  final String email;
  final String role;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? expiresAt;

  LoginResponse({
    this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'email': email,
      'role': role,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCashier => role.toLowerCase() == 'cashier';

  @override
  String toString() {
    return 'LoginResponse(userId: $userId, email: $email, role: $role)';
  }
}

/// Model untuk login error
class LoginError {
  final String message;
  final String? code;
  final int? statusCode;

  LoginError({
    required this.message,
    this.code,
    this.statusCode,
  });

  factory LoginError.fromException(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid api key') || errorString.contains('401')) {
      return LoginError(
        message: 'Konfigurasi API tidak valid. Pastikan Anda sudah mengisi .env dengan API key Supabase yang benar.',
        code: 'INVALID_API_KEY',
        statusCode: 401,
      );
    } else if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid credentials')) {
      return LoginError(
        message: 'Email atau password tidak cocok.',
        code: 'INVALID_CREDENTIALS',
        statusCode: 401,
      );
    } else if (errorString.contains('network')) {
      return LoginError(
        message: 'Tidak ada koneksi internet. Periksa koneksi Anda.',
        code: 'NETWORK_ERROR',
      );
    } else if (errorString.contains('timeout')) {
      return LoginError(
        message: 'Request timeout. Silakan coba lagi.',
        code: 'TIMEOUT',
      );
    } else if (errorString.contains('email not confirmed')) {
      return LoginError(
        message: 'Email belum diverifikasi. Silakan cek email Anda.',
        code: 'EMAIL_NOT_CONFIRMED',
      );
    }
    
    return LoginError(
      message: 'Login gagal. Periksa kembali data Anda.',
      code: 'UNKNOWN_ERROR',
    );
  }

  @override
  String toString() {
    return 'LoginError(message: $message, code: $code)';
  }
}