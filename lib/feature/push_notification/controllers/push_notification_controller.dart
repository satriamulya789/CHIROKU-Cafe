import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_notification_bottom_sheet.dart';
import 'package:chiroku_cafe/feature/push_notification/models/push_notification_model.dart';
import 'package:chiroku_cafe/feature/push_notification/repositories/push_notification_repositories.dart';
import 'package:chiroku_cafe/feature/push_notification/services/push_notification service.dart';
import 'package:chiroku_cafe/feature/push_notification/widgets/push_notification_card_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationController extends GetxController {
  final _repo = PushNotificationRepository();
  final _service = PushNotificationService();

  var notifications = <PushNotificationModel>[].obs;
  var isLoading = false.obs;

  void printFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }

  @override
  void onInit() {
    super.onInit();
    printFcmToken();
    _service.init();
    fetchNotifications();

    // Listen to FCM foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        final newNotif = PushNotificationModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: '',
          title: notification.title ?? 'Notification',
          message: notification.body ?? '',
          type: message.data['type'] ?? 'system',
          data: message.data,
          isRead: false,
          createdAt: DateTime.now(),
          readAt: null,
        );
        notifications.insert(0, newNotif);

        // Show NotificationBottomSheet with card builder
        NotificationsBottomSheet.show<PushNotificationModel>(
          notifications: notifications.toList(),
          onNotificationTap: (notif) {
            Get.back();
            // Add your custom action here if needed
          },
          notificationCardBuilder: (notif, onTap) => PushNotificationCardWidget(
            notification: notif,
            onTap: onTap,
          ),
          title: 'Push Notifications',
          icon: Icons.notifications,
        );
      }
    });
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      notifications.value = await _repo.fetchNotifications(userId);
    }
    isLoading.value = false;
  }
}