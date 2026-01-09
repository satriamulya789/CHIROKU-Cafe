import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/controllers/admin_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';
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
    ); // Add this line

    // Tambahkan controller lain sesuai kebutuhan untuk tab lainnya
    // Get.lazyPut<HomeAdminController>(() => HomeAdminController());
    // Get.lazyPut<MenuControlController>(() => MenuControlController());
    // Get.lazyPut<ReportAdminController>(() => ReportAdminController());
  }
}
