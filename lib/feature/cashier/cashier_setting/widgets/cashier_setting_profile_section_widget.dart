import 'package:chiroku_cafe/feature/cashier/cashier_setting/controllers/cashier_setting_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSectionWidget extends GetView<CashierSettingController> {
  const ProfileSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.userProfile.value;
      if (profile == null) return const SizedBox.shrink();

      final bool isAdmin = profile.role == UserRole.admin;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  backgroundColor: isAdmin ? AppColors.blueLight : AppColors.successLight,
                  child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: isAdmin ? AppColors.blueNormal : AppColors.successNormal,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.blueNormal : AppColors.successNormal,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.point_of_sale,
                      size: 12,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: AppTypography.h5.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          profile.email,
                          style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.blueNormal : AppColors.successNormal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.point_of_sale,
                          size: 10,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.role.toUpperCase(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final result = await Get.toNamed('/admin/edit-profile');
                if (result == true) controller.refreshProfile();
              },
            ),
          ],
        ),
      );
    });
  }
}