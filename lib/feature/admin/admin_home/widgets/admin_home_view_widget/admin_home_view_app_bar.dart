import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_user_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomeViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const AdminHomeViewAppBar({
    super.key,
    this.user,
    required this.unreadCount,
    required this.onNotificationTap, required AdminHomeController controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brownLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AssetsConstant.logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.store,
                    color: AppColors.brownNormal,
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chiroku Cafe',
                style: AppTypography.h6.copyWith(
                  color: AppColors.brownDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admin Dashboard',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brownNormal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.brownDarker,
              onPressed: onNotificationTap,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.alertNormal,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => Get.toNamed('/settings'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.brownLight,
              backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: AppColors.brownNormal,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}