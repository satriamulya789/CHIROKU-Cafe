import 'package:chiroku_cafe/feature/cashier/cashier_bottom_bar/controllers/cashier_bottom_bar_controller.dart';
import 'package:get/get.dart';

class CashierBottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierBottomBarController>(
      () => CashierBottomBarController(),
    );
  }
}