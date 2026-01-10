import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:get/get.dart';

class AdminEditCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminEditCategoryController>(() => AdminEditCategoryController());
  }
}