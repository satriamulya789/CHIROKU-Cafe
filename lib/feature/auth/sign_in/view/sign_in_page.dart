import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/controllers/sign_in_controller.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/sign_in_button.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/sign_in_dont_have_account.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/sign_in_forgot_password.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/shared/widgets/divider.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignInController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.toNamed(AppRoutes.signUp),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in to your\nAccount',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Enter your email and password to sign in ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                const SizedBox(height: 40),

                //Text Field
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: controller.emailController,
                  type: TextFieldType.email,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: controller.passwordController,
                  type: TextFieldType.password,
                  prefixIcon: Icons.lock_outline,
                  isPasswordVisible: controller.isPasswordObscured,
                ),
                const SizedBox(height: 20),
                SignInForgotPassword(),
                const SizedBox(height: 20),
                SignInButton(),
                const SizedBox(height: 40),
                DividerWidget(),
                const SizedBox(height: 40),
                SignInDontHaveAccount()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
