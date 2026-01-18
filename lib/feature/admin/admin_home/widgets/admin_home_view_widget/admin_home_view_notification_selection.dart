import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_notification_card_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class NotificationsSectionWidget extends StatelessWidget {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final VoidCallback onViewAll;
  final Function(NotificationModel) onTap;

  const NotificationsSectionWidget({
    super.key,
    required this.notifications,
    required this.unreadCount,
    required this.onViewAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.brownDarkActive,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Notifications & Alerts',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.brownDarker,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.alertLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount New',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.alertNormal,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notifications.map((notification) => NotificationCardWidget(
                notification: notification,
                onTap: () => onTap(notification),
              )),
        ],
      ),
    );
  }
}