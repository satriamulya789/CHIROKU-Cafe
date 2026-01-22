import 'package:chiroku_cafe/feature/cashier/cashier_bottom_bar/controllers/cashier_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/controllers/cashier_report_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/controllers/cashier_setting_controller.dart';
import 'package:get/get.dart';

class CashierBottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierBottomBarController>(() => CashierBottomBarController());
    Get.lazyPut<ReportCashierController>(() => ReportCashierController());
    Get.lazyPut<CashierSettingController>(() => CashierSettingController());
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
