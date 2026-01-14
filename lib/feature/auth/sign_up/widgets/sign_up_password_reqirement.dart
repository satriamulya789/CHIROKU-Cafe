import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class SignUpPasswordRequirement extends StatelessWidget {
  final String password;

  const SignUpPasswordRequirement({super.key, required this.password});

  /// Check if password has minimum length (6 characters)
  bool get hasMinLength => password.length >= 6;

  /// Check if password contains at least one uppercase letter
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));

  /// Check if password contains at least one lowercase letter
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));

  /// Check if password contains at least one number
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));

  /// Check if password contains at least one special character
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  /// Check if all requirements are met
  bool get isPasswordValid =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyNormal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.brownDarker,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem('At least 6 characters', hasMinLength),
          const SizedBox(height: 8),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          const SizedBox(height: 8),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          const SizedBox(height: 8),
          _buildRequirementItem('One number (0-9)', hasNumber),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'One special character (!@#\$%^&*)',
            hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        // Icon indicator
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet
                ? AppColors.successNormal
                : AppColors.greyNormal.withOpacity(0.3),
          ),
          child: Icon(
            isMet ? Icons.check : Icons.close,
            size: 14,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 12),
        // Requirement text
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isMet ? AppColors.successDark : AppColors.greyNormalHover,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
