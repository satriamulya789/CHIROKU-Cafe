import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final SplashRepository _repository;
  final RxString appVersion = '1.1.1'.obs;

  SplashController(this._repository);

  @override
  void onInit() {
    super.onInit();
    print('🚀 SplashController: onInit called');
    _startApp();
  }

  Future<void> _startApp() async {
    print('🚀 SplashController: Starting app timer...');
    // Adjusted duration to 3 seconds for a more premium transition
    await Future.delayed(const Duration(seconds: 3));
    print('🚀 SplashController: Timer finished, checking auth...');
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = _repository.currentSession;
      final user = _repository.currentUser;

      print('🚀 Auth Check: session=${session != null}, user=${user?.id}');

      if (session != null && user != null) {
        print('🚀 Auth Check: Fetching user role for ${user.id}...');
        final role = await _repository.getUserRole(user.id);
        print('🚀 Auth Check: Role found: $role');

        if (role == UserRole.admin) {
          print('🚀 Auth Check: Navigating to Admin Dashboard');
          Get.offAllNamed(AppRoutes.bottomBarAdmin);
        } else if (role == UserRole.cashier) {
          print('🚀 Auth Check: Navigating to Cashier Dashboard');
          Get.offAllNamed(AppRoutes.bottomBarCashier);
        } else {
          print('🚀 Auth Check: Unknown role, going to onboard');
          Get.offAllNamed(AppRoutes.onboard);
        }
      } else {
        print('🚀 Auth Check: No session, navigating to onboard');
        Get.offAllNamed(AppRoutes.onboard);
      }
    } catch (e) {
      print('❌ Auth Check Error: $e');
      // On error, go to onboard to prevent stuck splash
      Get.offAllNamed(AppRoutes.onboard);
    }
  }
}
