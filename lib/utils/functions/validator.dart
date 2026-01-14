import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

class Validator {
  String? ValidatorEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AuthErrorModel.emailEmpty().message;
    }

    if (!GetUtils.isEmail(email)) {
      return AuthErrorModel.invalidEmailFormat().message;
    }
    return null;
  }

  String? validatorName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return AuthErrorModel.nameEmpty().message;
    }
    return null;
  }

  String? validatorPassword(String? password) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
    );
    if (password == null || password.isEmpty) {
      return AuthErrorModel.passwordEmpty().message;
    }
    if (password.length < 6) {
      return AuthErrorModel.passwordTooShort().message;
    }
    if (!passwordRegex.hasMatch(password)) {
      return AuthErrorModel.passwordTooWeak().message;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AuthErrorModel.confirmPasswordEmpty().message;
    }
    if (value != password) {
      return AuthErrorModel.passwordDontMatch().message;
    }
    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AuthErrorModel.nameEmpty().message;
    }

    if (value.trim().length < 3) {
      return AuthErrorModel.nameTooShort().message;
    }

    if (value.trim().length > 50) {
      return AuthErrorModel.nameTooLong().message;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return AuthErrorModel.nameInvalidCharacters().message;
    }

    // Check if name has at least one non-space character
    if (value.trim().isEmpty) {
      return AuthErrorModel.nameOnlySpaces().message;
    }

    return null;
  }

  /// Validate if avatar is selected (optional)
  static String? validateAvatar(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return AuthErrorModel.avatarNotSelected().message;
    }
    return null;
  }

  /// Check if name contains valid characters only
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  /// Check minimum name length
  static bool hasMinimumLength(String name, {int minLength = 3}) {
    return name.trim().length >= minLength;
  }

  /// Check maximum name length
  static bool hasMaximumLength(String name, {int maxLength = 50}) {
    return name.trim().length <= maxLength;
  }

  /// Sanitize name (remove extra spaces)
  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
