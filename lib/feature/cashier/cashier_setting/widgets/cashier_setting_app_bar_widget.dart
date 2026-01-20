import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class CashierSettingAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const CashierSettingAppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
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
                style: AppTypography.appBarTitle.copyWith(
                  color: AppColors.brownDarkActive,
                ),
              ),
              Text(
                'Setting',
                style: AppTypography.appBarActionSmall.copyWith(
                  color: AppColors.brownNormal,
                ),
              ),
            ],
          ),
        ],
      ),
      // No actions (no avatar)
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}