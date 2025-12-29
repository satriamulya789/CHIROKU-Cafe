import 'package:chiroku_cafe/features/sign_in/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put - controller akan dibuat saat pertama kali diakses
    Get.lazyPut<LoginController>(() => LoginController());
  }
}