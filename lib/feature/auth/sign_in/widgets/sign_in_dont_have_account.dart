import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInDontHaveAccount extends StatelessWidget {
  const SignInDontHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: AppTypography.subtitleMedium.copyWith(
            color: AppColors.brownNormal,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.signUp),
          child: Text(
            'Sign Up',
            style: AppTypography.bodyLargeBold.copyWith(
              color: AppColors.brownDarker,
            ),
          ),
        ),
      ],
    );
  }
}