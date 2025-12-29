import 'package:get/get.dart';
import '../controllers/cashier_dashboard_controller.dart';

class CashierDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierDashboardController>(() => CashierDashboardController());
  }
}
