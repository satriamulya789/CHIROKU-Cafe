import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OnBoardView extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnBoardView({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              image,
              height: 475,
              width: 380,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          Text(title, style: AppTypography.h3.copyWith(color: AppColors.brownDarkActive), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.brownNormal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
