import 'package:chiroku_cafe/constant/assets_constant.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/splash_screen/controllers/splash_controller.dart';

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
            colors: [AppColors.white, AppColors.brownLight.withOpacity(0.3)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo with hero animation potential or just clean spacing
            Hero(
              tag: 'app_logo',
              child: Image.asset(AssetsConstant.logo, width: 180, height: 180),
            ),
            const SizedBox(height: 32),
            // Big Title
            Text(
              'CHIROKU CAFE',
              style: AppTypography.h1.copyWith(
                color: AppColors.brownDark,
                fontSize: 40,
                letterSpacing: 6,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            Text(
              'PREMIUM COFFEE & DELIGHTS',
              style: AppTypography.overlineLarge.copyWith(
                color: AppColors.brownNormal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(flex: 2),
            // Premium Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.brownNormal,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'v1.0.0',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
