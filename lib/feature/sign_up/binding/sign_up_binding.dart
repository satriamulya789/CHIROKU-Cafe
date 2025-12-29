import 'package:chiroku_cafe/feature/sign_up/controllers/sign_up_controller.dart';
import 'package:chiroku_cafe/feature/sign_up/repositories/sign_up_repositories.dart';
import 'package:chiroku_cafe/feature/sign_up/services/sign_up_service.dart';
import 'package:get/get.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize SignUpService
    Get.lazyPut<SignUpService>(() => SignUpService());

    // Initialize SignUpRepository with SignUpService
    Get.lazyPut<SignUpRepository>(
        () => SignUpRepository(Get.find<SignUpService>()));

    // Initialize SignUpController with SignUpRepository
    Get.lazyPut<SignUpController>(
        () => SignUpController(Get.find<SignUpRepository>()));
  }
}