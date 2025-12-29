import 'package:chiroku_cafe/configs/themes/theme.dart';
import 'package:flutter/material.dart';

class PasswordCriteriaItem extends StatelessWidget {
  final String text;
  final bool isValid;

  const PasswordCriteriaItem({
    Key? key,
    required this.text,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? AppColors.brownNormal : AppColors.brownLightActive,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? AppColors.brownDark : AppColors.brownNormalHover,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
