import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class AdminSettingManageQrisImageSourceDialogWidget extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const AdminSettingManageQrisImageSourceDialogWidget({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Choose Image Source',
        style: AppTypography.h6.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.brownDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ImageSourceTileWidget(
            icon: Icons.photo_library,
            title: 'Gallery',
            color: AppColors.blueNormal,
            onTap: onGalleryTap,
          ),
          const SizedBox(height: 8),
          _ImageSourceTileWidget(
            icon: Icons.camera_alt,
            title: 'Camera',
            color: AppColors.successNormal,
            onTap: onCameraTap,
          ),
        ],
      ),
    );
  }
}

class _ImageSourceTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceTileWidget({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.brownDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.brownNormal,
      ),
      onTap: onTap,
    );
  }
}