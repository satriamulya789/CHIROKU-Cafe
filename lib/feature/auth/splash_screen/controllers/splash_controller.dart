import 'dart:async';
import 'dart:developer';

import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_session_offline_repository.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashController extends GetxController {
  final SplashRepository _repository;
  final SessionRepository sessionRepository;
  final AppDatabase database;

  final RxString appVersion = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isOnline = true.obs;

  // ✅ Observable session (real-time dari database)
  final Rx<SessionLocal?> currentSession = Rx<SessionLocal?>(null);

  // ✅ StreamSubscription untuk watch session
  StreamSubscription<SessionLocal?>? _sessionSubscription;

  SplashController(this._repository, this.sessionRepository, this.database);

  @override
  void onInit() {
    super.onInit();
    log('🚀 SplashController: onInit called');
    _loadAppVersion();
    _checkInitialConnectivity();
    _listenConnectivity();

    // ✅ Watch session changes (real-time)
    _watchSessionChanges();

    _startApp();
  }

  @override
  void onClose() {
    // ✅ Cancel subscription saat controller di-dispose
    _sessionSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = '2.1.0'; // Fallback
    }
  }

  Future<void> _checkInitialConnectivity() async {
    isOnline.value = await sessionRepository.networkInfo.isConnected;
    log('🌐 Initial connectivity: ${isOnline.value}');
  }

  void _listenConnectivity() {
    sessionRepository.networkInfo.onConnectivityChanged.listen((online) async {
      isOnline.value = online;
      if (online) {
        log('🌐 Network: Back online, syncing session...');
        await sessionRepository.syncSessionOnline();
      } else {
        log('📴 Network: Offline mode activated');
      }
    });
  }

  /// ✅ Watch session changes from database (real-time)
  void _watchSessionChanges() {
    log('👂 Setting up real-time session watcher...');

    _sessionSubscription = database.watchSession().listen((session) {
      currentSession.value = session;

      if (session != null) {
        log(
          '👂 Session changed: userId=${session.userId}, role=${session.role}',
        );
      } else {
        log('👂 Session cleared from database');
      }
    });
  }

  Future<void> _startApp() async {
    log('🚀 SplashController: Starting app timer...');
    await Future.delayed(const Duration(seconds: 3));
    log('🚀 SplashController: Timer finished, checking auth...');
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      isLoading.value = true;

      // ✅ Use getCurrentSessionLocal (has role info, works offline)
      final localSession = await sessionRepository.getCurrentSessionLocal();

      log(
        '🚀 Auth Check: session=${localSession != null}, online=${isOnline.value}',
      );

      if (localSession != null) {
        log('🚀 Auth Check: User ID: ${localSession.userId}');
        log('🚀 Auth Check: Role: ${localSession.role}');

        // ✅ Navigate based on role from local session (works offline)
        _navigateByRole(localSession.role);
      } else {
        log('🚀 Auth Check: No session, navigating to onboard');
        Get.offAllNamed(AppRoutes.onboard);
      }
    } catch (e) {
      log('❌ Auth Check Error: $e');
      Get.offAllNamed(AppRoutes.onboard);
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate by role (using string comparison)
  void _navigateByRole(String role) {
    if (role == 'admin') {
      log('🚀 Auth Check: Navigating to Admin Dashboard');
      Get.offAllNamed(AppRoutes.bottomBarAdmin);
    } else if (role == 'cashier') {
      log('🚀 Auth Check: Navigating to Cashier Dashboard');
      Get.offAllNamed(AppRoutes.bottomBarCashier);
    } else {
      log('🚀 Auth Check: Unknown role ($role), going to onboard');
      Get.offAllNamed(AppRoutes.onboard);
    }
  }

  /// Public method to re-check session (for manual refresh)
  Future<void> checkSession() async {
    await _checkAuthStatus();
  }
}
