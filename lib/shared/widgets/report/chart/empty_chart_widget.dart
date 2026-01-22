import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class EmptyChartWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyChartWidget({
    super.key,
    this.title = 'No Sales Data',
    this.subtitle = 'There is no sales data for the selected period.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.brownLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: AppColors.brownNormal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.bodyLargeBold.copyWith(
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.greyNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
