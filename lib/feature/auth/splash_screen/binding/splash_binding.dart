import 'package:chiroku_cafe/feature/auth/splash_screen/controllers/splash_controller.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/splash_service.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashService>(() => SplashService());
    Get.lazyPut<SplashRepository>(
      () => SplashRepository(Get.find<SplashService>()),
    );
    Get.put<SplashController>(SplashController(Get.find<SplashRepository>()));
  }
}
