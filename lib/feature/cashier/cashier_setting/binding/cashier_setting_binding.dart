import 'package:chiroku_cafe/feature/cashier/cashier_setting/controllers/cashier_setting_controller.dart';
import 'package:get/get.dart';

class CashierSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierSettingController>(() => CashierSettingController());
  }
}