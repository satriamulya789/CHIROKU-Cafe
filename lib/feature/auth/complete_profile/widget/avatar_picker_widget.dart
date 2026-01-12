import 'dart:io';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';

class AvatarPickerWidget extends StatelessWidget {
  final File? avatarFile;
  final bool isUploading;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const AvatarPickerWidget({
    super.key,
    required this.avatarFile,
    required this.isUploading,
    required this.onTap,
    required this.onRemove, String? avatarUrl, File? selectedImage, required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDarker,
            ),
          ),
          const SizedBox(height: 24),

          // Avatar Circle
          _buildAvatarCircle(),

          const SizedBox(height: 24),

          // Upload Button or Remove Option
          if (avatarFile == null) _buildUploadButton() else _buildRemoveOption(),
        ],
      ),
    );
  }

  /// Build Avatar Circle with Simple Border
  Widget _buildAvatarCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circle Border
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: avatarFile != null
                  ? AppColors.brownNormal
                  : AppColors.brownNormal.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brownNormal.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarFile != null
                  ? Colors.transparent
                  : AppColors.brownLight.withOpacity(0.5),
            ),
            child: avatarFile != null
                ? ClipOval(
                    child: Image.file(
                      avatarFile!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person_outline,
                    size: 60,
                    color: AppColors.brownNormal.withOpacity(0.5),
                  ),
          ),
        ),

        // Loading Overlay
        if (isUploading)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brownDarker.withOpacity(0.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }

  /// Build Upload Button
  Widget _buildUploadButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brownNormal, AppColors.brownDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownNormal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isUploading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.brownLight,
          disabledForegroundColor: AppColors.brownNormal,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.upload_outlined, size: 20),
        label: const Text(
          'Upload Photo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build Remove Option - Improved Design
  Widget _buildRemoveOption() {
    return Column(
      children: [
        // Success Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.successNormal.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.successNormal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Photo Selected',
                style: TextStyle(
                  color: AppColors.successNormal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Change Photo Button - Outlined Style
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownNormal,
                side: BorderSide(
                  color: AppColors.brownNormal.withOpacity(0.5),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Remove Button - Filled Style
            ElevatedButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Remove',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertNormal.withOpacity(0.1),
                foregroundColor: AppColors.alertNormal,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}