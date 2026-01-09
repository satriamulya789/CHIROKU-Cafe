import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_notification_card_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsBottomSheet extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Function(NotificationModel) onNotificationTap;

  const NotificationsBottomSheet({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
  });

  static void show({
    required List<NotificationModel> notifications,
    required Function(NotificationModel) onNotificationTap,
  }) {
    Get.bottomSheet(
      NotificationsBottomSheet(
        notifications: notifications,
        onNotificationTap: onNotificationTap,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brownLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Notifications',
                  style: AppTypography.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownDarker,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  color: AppColors.brownNormal,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.brownNormal.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.brownNormal,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationCardWidget(
                        notification: notifications[index],
                        onTap: () => onNotificationTap(notifications[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}