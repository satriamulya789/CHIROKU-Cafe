import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class SettingItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color icColor = iconColor ?? AppColors.blueNormal;
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.18)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: icColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: icColor, size: 22),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        onTap: onTap,
      ),
    );
  }
}