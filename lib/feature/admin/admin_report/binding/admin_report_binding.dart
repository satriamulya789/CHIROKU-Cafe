import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:get/get.dart';

class ReportAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportAdminController());
  }
}