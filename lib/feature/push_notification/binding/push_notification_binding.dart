import 'package:get/get.dart';
import '../controllers/push_notification_controller.dart';

class PushNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PushNotificationController());
  }
}