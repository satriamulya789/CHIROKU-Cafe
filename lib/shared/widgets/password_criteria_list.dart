import 'package:chiroku_cafe/shared/widgets/password_criteria_item.dart';
import 'package:chiroku_cafe/configs/themes/theme.dart';
import 'package:flutter/material.dart';

class PasswordCriteriaList extends StatelessWidget {
  final Map<String, bool> criteria;

  const PasswordCriteriaList({Key? key, required this.criteria})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brownLightActive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 8),
          PasswordCriteriaItem(
            text: 'At least 8 characters',
            isValid: criteria['length'] ?? false,
          ),
          PasswordCriteriaItem(
            text: 'Lowercase letter (a-z)',
            isValid: criteria['lowercase'] ?? false,
          ),
          PasswordCriteriaItem(
            text: 'Uppercase letter (A-Z)',
            isValid: criteria['uppercase'] ?? false,
          ),
          PasswordCriteriaItem(
            text: 'Number (0-9)',
            isValid: criteria['digit'] ?? false,
          ),
          PasswordCriteriaItem(
            text: 'Symbol (!@#\$%^&*)',
            isValid: criteria['symbol'] ?? false,
          ),
        ],
      ),
    );
  }
}
