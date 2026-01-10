import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:get/get.dart';

class AdminEditMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminEditMenuController>(() => AdminEditMenuController());
  }
}