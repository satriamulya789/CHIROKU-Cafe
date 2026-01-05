import 'package:chiroku_cafe/feature/auth/reset_password/controllers/reset_password_controllers.dart';
import 'package:get/get.dart';

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
  }
}