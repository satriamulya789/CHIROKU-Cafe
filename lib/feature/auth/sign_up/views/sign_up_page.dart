import 'package:chiroku_cafe/feature/auth/sign_in/widgets/email_text_field.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/controllers/sign_up_controller.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/widgets/sign_up_already_have_acc.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/widgets/sign_up_button.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/shared/widgets/divider.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create an Account',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Create an account to continue!',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                const SizedBox(height: 40),
                
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

                 // Confirm Password Field
                 CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: controller.confirmPasswordController,
                  type: TextFieldType.password,
                  prefixIcon: Icons.lock_outline,
                  isPasswordVisible: controller.isConfirmPasswordObscured,
                  customValidator: (value) {
                    // Order parameter: value dulu, password kedua
                    return controller.validator.validateConfirmPassword(
                      value,
                      controller.passwordController.text,
                    );
                  },
                ),
                const SizedBox(height: 30),


                

                //Full Name Text Field

                ButtonSignUp(),
                const SizedBox(height: 40),
                DivenderWidget(),
                SizedBox(height: 24),
                AlreadyHaveAccount(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
