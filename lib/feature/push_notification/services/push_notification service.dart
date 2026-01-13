import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    FirebaseMessaging.onMessage.listen(_showNotification);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const androidDetails = AndroidNotificationDetails(
      'chiroku_cafe_notifications',
      'Chiroku Cafe Notifications',
      channelDescription: 'Notifications for Chiroku Cafe',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<String?> getToken() => _fcm.getToken();
}