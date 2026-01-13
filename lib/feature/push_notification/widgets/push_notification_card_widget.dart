import 'package:flutter/material.dart';
import '../../../shared/style/app_color.dart';
import '../../../shared/style/google_text_style.dart';
import '../../../constant/assets_constant.dart';
import '../models/push_notification_model.dart';

class PushNotificationCardWidget extends StatelessWidget {
  final PushNotificationModel notification;
  final VoidCallback? onTap; // Jadikan opsional

  const PushNotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap, // opsional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead ? AppColors.white : AppColors.brownLight,
      child: ListTile(
        leading: Image.asset(AssetsConstant.logo, width: 36, height: 36),
        title: Text(
          notification.title,
          style: AppTypography.h1.copyWith(
            color: AppColors.brownLightHover,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.message,
          style: AppTypography.h1.copyWith(
            color: AppColors.brownLightHover,
          ),
        ),
        trailing: notification.isRead
            ? null
            : Icon(Icons.circle, color: AppColors.brownLightHover, size: 12),
        onTap: onTap, // gunakan onTap jika ada
      ),
    );
  }
}