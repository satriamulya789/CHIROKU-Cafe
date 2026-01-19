import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_user_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class AdminManageControlAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final String currentTitle;
  final VoidCallback? onProfileTap;

  const AdminManageControlAppBar({
    super.key,
    this.user,
    required this.currentTitle,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.brownNormal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.brownNormal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Control',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.brownDarker,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentTitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brownNormal.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.fullName ?? '-',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brownDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        user!.role ?? 'Admin',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brownNormal.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // CircleAvatar dihapus
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}