import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlreadyHaveAccount extends StatelessWidget {
  const AlreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.brownDark,
          ),
        ),
        SizedBox(width: 4,),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.signIn),
          child: Text(
            'Sign In',
            style: AppTypography.bodyMediumBold.copyWith(
              color: AppColors.brownDarkActive
            ),
          ),
        ),
      ],
    );
  }
}