import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:get/get.dart';

class AdminManageControlBinding extends Bindings {
  @override
  void dependencies() {
    // Main controller
    Get.lazyPut<AdminManageControlController>(
      () => AdminManageControlController(),
    );

    // Sub controllers
    Get.lazyPut<AdminEditUserController>(
      () => AdminEditUserController(),
      fenix: true,
    );
    
    Get.lazyPut<AdminEditMenuController>(
      () => AdminEditMenuController(),
      fenix: true,
    );
    
    Get.lazyPut<AdminEditCategoryController>(
      () => AdminEditCategoryController(),
      fenix: true,
    );
    
    Get.lazyPut<AdminEditTableController>(
      () => AdminEditTableController(),
      fenix: true,
    );
  }
}