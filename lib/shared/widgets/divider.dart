import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DivenderWidget extends StatelessWidget {
  const DivenderWidget({super.key});

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTypography.bodySmall.copyWith(color:  AppColors.brownNormal),
            ),
          ),
        const Expanded(child: Divider()),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildDivider();
  }
}