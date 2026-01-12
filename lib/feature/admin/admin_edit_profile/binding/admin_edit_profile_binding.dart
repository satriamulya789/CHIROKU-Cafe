import 'package:chiroku_cafe/feature/admin/admin_edit_profile/controllers/admin_edit_profile_controller.dart';
import 'package:get/get.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(),
    );
  }
}