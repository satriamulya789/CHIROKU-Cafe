import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/auth/splash_screen/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    controller.onInit;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, AppColors.brownLight.withOpacity(0.2)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main Content - Perfectly Centered
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      AssetsConstant.logo,
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'CHIROKU CAFE',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.brownDark,
                      fontSize: 32,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PREMIUM COFFEE & DELIGHTS',
                    style: AppTypography.overlineLarge.copyWith(
                      color: AppColors.brownNormal,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // App Version at the very bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Obx(
                  () => Text(
                    'Version ${controller.appVersion.value}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.greyNormal,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
