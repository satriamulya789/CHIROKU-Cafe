import 'package:chiroku_cafe/feature/cashier/cashier_report/controllers/cashier_report_controller.dart';
import 'package:get/get.dart';

class ReportCashierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportCashierController>(() => ReportCashierController());
  }
}
