import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class EmptyChartWidget extends StatelessWidget {
  const EmptyChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 64,
            color: AppColors.brownNormal.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Sales Data Available',
            style: AppTypography.h6.copyWith(
              color: AppColors.brownNormal.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sales data will appear here\nwhen orders are completed',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.brownNormal.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}