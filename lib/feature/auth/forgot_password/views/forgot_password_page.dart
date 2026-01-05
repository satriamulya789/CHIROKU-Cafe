import 'package:chiroku_cafe/feature/auth/forgot_password/controllers/forgot_password_controller.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/widgets/forgot_password_button.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();
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
                  'Forgot Your Password ?',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Don\'t worry! It happens. Please enter the email address associated with your account.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                SizedBox(height: 40),
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: controller.emailController,
                  type: TextFieldType.email,
                ),
                SizedBox(height: 32),
                ForgotPasswordButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
