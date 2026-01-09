import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';

class HomeAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
  }
}