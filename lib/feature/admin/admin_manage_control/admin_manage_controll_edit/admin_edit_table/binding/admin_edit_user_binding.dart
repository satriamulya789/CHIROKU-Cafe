import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controlle.dart';
import 'package:get/get.dart';

class AdminEditTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminEditTableController>(() => AdminEditTableController());
  }
}