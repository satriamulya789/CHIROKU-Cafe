import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsBottomSheet<T> extends StatelessWidget {
  final List<T> notifications;
  final Function(T) onNotificationTap;
  final Widget Function(T, VoidCallback) notificationCardBuilder;
  final String title;
  final IconData? icon;

  const NotificationsBottomSheet({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    required this.notificationCardBuilder,
    this.title = 'All Notifications',
    this.icon,
  });

  static void show<T>({
    required List<T> notifications,
    required Function(T) onNotificationTap,
    required Widget Function(T, VoidCallback) notificationCardBuilder,
    String title = 'All Notifications',
    IconData? icon,
  }) {
    Get.bottomSheet(
      NotificationsBottomSheet<T>(
        notifications: notifications,
        onNotificationTap: onNotificationTap,
        notificationCardBuilder: notificationCardBuilder,
        title: title,
        icon: icon,
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
                Row(
                  children: [
                    if (icon != null)
                      Icon(icon, color: AppColors.brownDarker),
                    if (icon != null) const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownDarkActive,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  color: AppColors.brownDarkActive,
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
                      return notificationCardBuilder(
                        notifications[index],
                        () => onNotificationTap(notifications[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}