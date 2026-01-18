import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/controllers/admin_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/controllers/admin_setting_controller.dart';
import 'package:get/get.dart';

class AdminBottomBarBinding extends Bindings {
  @override
  void dependencies() {
    // Bottom Bar Controller
    Get.lazyPut<BottomBarController>(() => BottomBarController());

    // Settings Controller (akan otomatis di-load ketika tab Settings dibuka)
    Get.lazyPut<AdminSettingController>(() => AdminSettingController());
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(),
    ); 
    Get.lazyPut<AdminManageControlController>(() => AdminManageControlController());
    Get.lazyPut<ReportAdminController>(() => ReportAdminController());
  }
}
