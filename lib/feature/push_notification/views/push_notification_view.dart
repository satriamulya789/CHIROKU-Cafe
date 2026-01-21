import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/push_notification_controller.dart';
import '../widgets/push_notification_card_widget.dart';
import '../../../shared/style/app_color.dart';
import '../../../shared/style/google_text_style.dart';

class PushNotificationView extends GetView<PushNotificationController> {
  const PushNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.h1),
        backgroundColor: AppColors.brownLightHover,
        foregroundColor: AppColors.brownLight,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications yet',
              style: AppTypography.h1.copyWith(
                color: AppColors.brownLightHover,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, i) => PushNotificationCardWidget(
            notification: controller.notifications[i],
          ),
        );
      }),
    );
  }
}
