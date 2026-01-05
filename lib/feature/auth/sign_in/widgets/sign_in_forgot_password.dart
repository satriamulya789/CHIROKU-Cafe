import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInForgotPassword extends StatelessWidget {
  const SignInForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.forgotPassword),
          child: Text(
            'Forgot Password?',
            style: AppTypography.label.copyWith(
              color: AppColors.brownDarker,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}