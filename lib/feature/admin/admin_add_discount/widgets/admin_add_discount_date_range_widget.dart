import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class DateRangeButtonWidget extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const DateRangeButtonWidget({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        date == null
            ? label
            : '$label: ${_formatDate(date!)}',
        style: AppTypography.bodyMedium,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
    );
  }

  String _formatDate(DateTime date) {
    // Format: yyyy-MM-dd
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}