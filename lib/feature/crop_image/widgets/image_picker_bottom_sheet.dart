import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImagePickerBottomSheet({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pick Image Source',
            style: AppTypography.h6.copyWith(color: AppColors.brownDarker),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerItem(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () {
                  Get.back();
                  onCameraTap();
                },
                color: AppColors.blueNormal,
              ),
              _buildPickerItem(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () {
                  Get.back();
                  onGalleryTap();
                },
                color: AppColors.orangeNormal,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPickerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.brownDarker,
            ),
          ),
        ],
      ),
    );
  }
}
