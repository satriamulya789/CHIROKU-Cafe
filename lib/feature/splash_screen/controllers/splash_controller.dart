import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final SplashRepository _repository;

  SplashController(this._repository);

  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  Future<void> _startApp() async {
    // Add a small delay for splash visual
    await Future.delayed(const Duration(seconds: 2));
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final session = _repository.currentSession;
    final user = _repository.currentUser;

    if (session != null && user != null) {
      final role = await _repository.getUserRole(user.id);

      if (role == UserRole.admin) {
        Get.offAllNamed(AppRoutes.bottomBarAdmin);
      } else if (role == UserRole.cashier) {
        Get.offAllNamed(AppRoutes.bottomBarCashier);
      } else {
        // If role is null or unknown, go to onboard
        Get.offAllNamed(AppRoutes.onboard);
      }
    } else {
      // User not logged in, go to onboard
      Get.offAllNamed(AppRoutes.onboard);
    }
  }
}
