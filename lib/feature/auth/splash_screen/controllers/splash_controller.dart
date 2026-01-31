import 'dart:developer';

import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashController extends GetxController {
  final SplashRepository _repository;
  final RxString appVersion = ''.obs;

  SplashController(this._repository);

  @override
  void onInit() {
    super.onInit();
    log('SplashController: onInit called');
    _loadAppVersion();
    _startApp();
  }

  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = '1.2.0'; // Fallback
    }
  }

  Future<void> _startApp() async {
    log('SplashController: Starting app timer...');
    // Adjusted duration to 3 seconds for a more premium transition
    await Future.delayed(const Duration(seconds: 3));
    log('SplashController: Timer finished, checking auth...');
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = await _repository.getSession();

      log('Auth Check: session=${session != null}, userId=${session?.userId}');

      if (session != null) {
        final role = _repository.getUserRoleFromSession(session);
        log('Auth Check: Role found: $role');

        if (role == UserRole.admin) {
          log('Auth Check: Navigating to Admin Dashboard');
          Get.offAllNamed(AppRoutes.bottomBarAdmin);
        } else if (role == UserRole.cashier) {
          log('Auth Check: Navigating to Cashier Dashboard');
          Get.offAllNamed(AppRoutes.bottomBarCashier);
        } else {
          log('Auth Check: Unknown role, going to onboard');
          Get.offAllNamed(AppRoutes.onboard);
        }
      } else {
        log('Auth Check: No session, navigating to onboard');
        Get.offAllNamed(AppRoutes.onboard);
      }
    } catch (e) {
      log('Auth Check Error: $e');
      // On error, go to onboard to prevent stuck splash
      Get.offAllNamed(AppRoutes.onboard);
    }
  }
}
