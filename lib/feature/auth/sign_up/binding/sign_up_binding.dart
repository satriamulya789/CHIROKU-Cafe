import 'package:chiroku_cafe/feature/auth/sign_up/controllers/sign_up_controller.dart';
import 'package:get/get.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize SignUpService
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}