import 'package:chiroku_cafe/feature/auth/complete_profile/controllers/complete_profile_controller.dart';
import 'package:get/get.dart';

class CompleteProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompleteProfileController>(
      () => CompleteProfileController(),
    );
  }
}