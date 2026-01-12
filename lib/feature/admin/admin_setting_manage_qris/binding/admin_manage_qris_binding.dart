import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/controllers/admin_setting_manage_qris_controller.dart';
import 'package:get/get.dart';

class PaymentSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentSettingsController>(
      () => PaymentSettingsController(),
    );
  }
}