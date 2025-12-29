class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};

  @override
  String toString() => 'ForgotPasswordRequest(email: $email)';
}

/// Model untuk forgot password response
class ForgotPasswordResponse {
  final bool emailExists;
  final String email;
  final String? message;

  ForgotPasswordResponse({
    required this.emailExists,
    required this.email,
    this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      emailExists: json['email_exists'] as bool? ?? false,
      email: json['email'] as String,
      message: json['message'] as String?,
    );
  }

  @override
  String toString() =>
      'ForgotPasswordResponse(emailExists: $emailExists, email: $email)';
}

/// Model untuk reset password request
class ResetPasswordRequest {
  final String email;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'new_password': newPassword,
      };

  @override
  String toString() => 'ResetPasswordRequest(email: $email)';
}

/// Model untuk password error
class PasswordError implements Exception {
  final String message;
  final String? code;

  PasswordError({required this.message, this.code});

  factory PasswordError.fromException(dynamic e) {
    final s = e.toString().toLowerCase();
    if (s.contains('not found') || s.contains('does not exist')) {
      return PasswordError(
        message: 'Email tidak ditemukan',
        code: 'EMAIL_NOT_FOUND',
      );
    } else if (s.contains('network')) {
      return PasswordError(
        message: 'Tidak ada koneksi internet',
        code: 'NETWORK_ERROR',
      );
    } else if (s.contains('timeout')) {
      return PasswordError(
        message: 'Request timeout. Silakan coba lagi',
        code: 'TIMEOUT',
      );
    } else if (s.contains('invalid') || s.contains('401')) {
      return PasswordError(
        message: 'Sesi tidak valid. Silakan login kembali',
        code: 'INVALID_SESSION',
      );
    }
    return PasswordError(
      message: 'Terjadi kesalahan. Silakan coba lagi',
      code: 'UNKNOWN',
    );
  }

  @override
  String toString() => 'PasswordError(message: $message, code: $code)';
}

/// Password strength enum
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong,
}

/// Password validator utility
class PasswordValidator {
  /// Validate password with all requirements
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password harus mengandung simbol';
    }
    return null;
  }

  /// Check password strength
  static PasswordStrength checkStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    int score = 0;

    // Length criteria
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character type criteria
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Determine strength based on score
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    if (score <= 4) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  /// Get password criteria status
  static Map<String, bool> getCriteria(String password) {
    return {
      'length': password.length >= 8,
      'lowercase': RegExp(r'[a-z]').hasMatch(password),
      'uppercase': RegExp(r'[A-Z]').hasMatch(password),
      'digit': RegExp(r'[0-9]').hasMatch(password),
      'symbol': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}