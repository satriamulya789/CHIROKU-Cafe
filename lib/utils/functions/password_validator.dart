import 'package:chiroku_cafe/shared/models/auth_error_model.dart';

/// Password validator utility class
class PasswordValidator {
  /// Validate password and return appropriate error model if invalid
  static AuthErrorModel? validate(String password) {
    // Check if password is empty
    if (password.isEmpty) {
      return AuthErrorModel.passwordEmpty();
    }

    // Check minimum length
    if (password.length < 6) {
      return AuthErrorModel.passwordTooShort();
    }

    // Check password complexity
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecialChar) {
      return AuthErrorModel.passwordTooWeak();
    }

    // Password is valid
    return null;
  }

  /// Check if password meets all requirements
  static bool isValid(String password) {
    return validate(password) == null;
  }

  /// Get password strength (0-5)
  static int getStrength(String password) {
    int strength = 0;

    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  /// Get password strength label
  static String getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
}
