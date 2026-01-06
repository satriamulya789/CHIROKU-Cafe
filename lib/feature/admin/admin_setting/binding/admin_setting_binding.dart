import 'package:chiroku_cafe/feature/admin/admin_setting/controllers/admin_setting_controller.dart';
import 'package:get/get.dart';

class AdminSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSettingController>(() => AdminSettingController());
  }
}