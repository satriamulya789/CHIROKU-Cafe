import 'package:chiroku_cafe/configs/themes/theme.dart';
import 'package:flutter/material.dart';

class PasswordValidator {
  // Validasi password dengan kriteria lengkap
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil (a-z)';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar (A-Z)';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka (0-9)';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password harus mengandung simbol (!@#%^&*...)';
    }

    return null;
  }

  static PasswordStrength checkStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  static Map<String, bool> getCriteria(String password) {
    return {
      'length': password.length >= 8,
      'lowercase': password.contains(RegExp(r'[a-z]')),
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'digit': password.contains(RegExp(r'[0-9]')),
      'symbol': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }
}

enum PasswordStrength { empty, weak, medium, strong, veryStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({Key? key, required this.strength})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getStrengthText(),
          style: TextStyle(
            fontSize: 12,
            color: _getTextColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getColor(int index) {
    switch (strength) {
      case PasswordStrength.weak:
        return index == 0 ? AppColors.brownDark : AppColors.brownLightActive;
      case PasswordStrength.medium:
        return index <= 1 ? AppColors.brownNormal : AppColors.brownLightActive;
      case PasswordStrength.strong:
        return AppColors.brownNormalActive;
      default:
        return AppColors.brownLightActive;
    }
  }

  Color _getTextColor() {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.brownDark;
      case PasswordStrength.medium:
        return AppColors.brownNormal;
      case PasswordStrength.strong:
        return AppColors.brownNormalActive;
      default:
        return AppColors.brownNormalHover;
    }
  }

  String _getStrengthText() {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Password lemah';
      case PasswordStrength.medium:
        return 'Password sedang';
      case PasswordStrength.strong:
        return 'Password kuat';
      default:
        return '';
    }
  }
}
