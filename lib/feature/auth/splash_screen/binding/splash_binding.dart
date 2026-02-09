import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/controllers/splash_controller.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_repository.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/repositories/splash_session_offline_repository.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/services/splash_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Inject SplashService
    Get.lazyPut<SplashService>(
      () => SplashService(),
    );

    // Inject SessionRepository
    Get.lazyPut<SessionRepository>(
      () => SessionRepository(
        supabase: Supabase.instance.client,
        database: Get.find<AppDatabase>(),
        networkInfo: Get.find<NetworkInfo>(),
      ),
    );

    // Inject SplashRepository
    Get.lazyPut<SplashRepository>(
      () => SplashRepository(
        Get.find<SplashService>(),
        Get.find<AppDatabase>(),
        Get.find<NetworkInfo>(),
      ),
    );

    // Inject SplashController
    Get.lazyPut<SplashController>(
      () => SplashController(
        Get.find<SplashRepository>(),
        Get.find<SessionRepository>(),
        Get.find<AppDatabase>(),
      ),
    );
  }
}