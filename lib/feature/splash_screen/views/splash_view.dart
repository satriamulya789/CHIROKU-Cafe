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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(AssetsConstant.logo, width: 150, height: 150),
            const SizedBox(height: 24),
            // App Name or Tagline
            Text(
              'CHIROKU CAFE',
              style: AppTypography.h4.copyWith(
                color: AppColors.brownNormal,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium Coffee & More',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              color: AppColors.brownNormal,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
