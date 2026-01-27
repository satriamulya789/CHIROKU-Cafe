import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:chiroku_cafe/shared/widgets/offline_badge_widget.dart';
import 'package:chiroku_cafe/shared/services/connectivity_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Obx(() => OfflineBadgeWidget(
              isOffline: !connectivity.isConnected,
              child: _buildAvatar(),
            )),
        title: Text(
          user.fullName,
          style: AppTypography.h6.copyWith(color: AppColors.brownDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (user.email != null)
              Text(
                user.email!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brownNormal,
                ),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.role == 'admin'
                    ? AppColors.purpleLight
                    : AppColors.blueLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: user.role == 'admin'
                      ? AppColors.purpleNormal
                      : AppColors.blueNormal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.blueNormal),
              onPressed: onEdit,
              tooltip: 'Edit User',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.alertNormal),
              onPressed: onDelete,
              tooltip: 'Delete User',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Handle offline or pending upload avatars
    if (user.avatarUrl == null || 
        user.avatarUrl!.isEmpty || 
        user.avatarUrl == 'pending_upload') {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.brownLight,
        child: Text(
          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownNormal,
          ),
        ),
      );
    }

    // Use cached network image for online avatars
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.brownLight,
      backgroundImage: CachedNetworkImageProvider(user.avatarUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // Fallback if image fails to load
      },
      child: null,
    );
  }
}