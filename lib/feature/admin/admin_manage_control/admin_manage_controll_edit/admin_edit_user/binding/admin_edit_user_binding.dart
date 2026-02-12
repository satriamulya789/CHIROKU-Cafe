import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:get/get.dart';

class AdminEditUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync(() => DatabaseHelper().init(), permanent: true);
    Get.lazyPut<AdminEditUserController>(() => AdminEditUserController());
  }
}
