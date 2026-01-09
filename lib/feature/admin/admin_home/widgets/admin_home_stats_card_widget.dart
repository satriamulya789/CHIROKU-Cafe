import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool showTrend;
  final double? trendValue;
  final VoidCallback? onTap;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.showTrend = false,
    this.trendValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: color.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.label.copyWith(
                color: AppColors.brownDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brownNormal,
                ),
              ),
            ],
            if (showTrend && trendValue != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    trendValue! >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: trendValue! >= 0
                        ? AppColors.successNormal
                        : AppColors.alertNormal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trendValue!.abs().toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: trendValue! >= 0
                          ? AppColors.successNormal
                          : AppColors.alertNormal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'from yesterday',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.brownNormal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}