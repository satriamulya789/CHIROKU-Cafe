import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminStatsCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isOffline;

  const AdminStatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerCard();
    }

    return Container(
      padding: const EdgeInsets.all(8), // ✅ Reduced from 12 to 8
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOffline 
              ? AppColors.greyNormal.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ Center content
        mainAxisSize: MainAxisSize.min, // ✅ Use minimum space
        children: [
          // Icon with offline indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isOffline ? AppColors.greyNormal : color,
                size: 16, // ✅ Reduced from 18 to 16
              ),
              if (isOffline)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 6, // ✅ Reduced from 8 to 6
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.alertNormal,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 0.5, // ✅ Thinner border
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4), // ✅ Reduced from 8 to 4
          
          // Count
          Text(
            count.toString(),
            style: AppTypography.label.copyWith(
              color: isOffline ? AppColors.greyNormal : color,
              fontWeight: FontWeight.bold,
              fontSize: 14, // ✅ Explicit size
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2), // ✅ Reduced from 4 to 2
          
          // Title
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: isOffline 
                  ? AppColors.greyNormal 
                  : AppColors.brownDark,
              fontSize: 9, // ✅ Smaller font
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Offline badge
          if (isOffline) ...[
            const SizedBox(height: 2), // ✅ Reduced spacing
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4, // ✅ Reduced from 6 to 4
                vertical: 1,   // ✅ Reduced from 2 to 1
              ),
              decoration: BoxDecoration(
                color: AppColors.alertLight,
                borderRadius: BorderRadius.circular(3), // ✅ Smaller radius
              ),
              child: Text(
                'Offline',
                style: AppTypography.caption.copyWith(
                  color: AppColors.alertDark,
                  fontSize: 7, // ✅ Smaller font
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.greyLight,
      highlightColor: AppColors.white,
      child: Container(
        padding: const EdgeInsets.all(8), // ✅ Reduced padding
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.greyNormal.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16, // ✅ Smaller icon placeholder
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 24, // ✅ Smaller count placeholder
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 32, // ✅ Smaller title placeholder
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}