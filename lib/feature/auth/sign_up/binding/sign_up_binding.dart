import 'package:chiroku_cafe/feature/auth/sign_up/controllers/sign_up_controller.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/services/sign_up_service.dart';
import 'package:get/get.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize SignUpService
    Get.lazyPut<SignUpService>(() => SignUpService());
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}