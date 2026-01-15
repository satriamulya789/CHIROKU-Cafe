import 'package:chiroku_cafe/feature/auth/reset_password/controllers/reset_password_controllers.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/widgets/reset_password_button.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();
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
                  'Reset Your Password',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please enter your new password below to reset your account password.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                SizedBox(height: 40),
                CustomTextField(
                  label: 'New Password',
                  hintText: 'Enter your new password',
                  controller: controller.newPasswordController,
                  type: TextFieldType.password,
                  isPasswordVisible: controller.isNewPasswordObscured,
                ),
                SizedBox(height: 16),
                              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                controller: controller.confirmPasswordController,
                type: TextFieldType.password,
                isPasswordVisible: controller.isConfirmPasswordObscured,
                customValidator: (value) {
                  if (value != controller.newPasswordController.text) {
                    return AuthErrorModel.passwordDontMatch().message;
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ResetPasswordButton()

              ],
            ),
          ),
        ),
      ),
    );
  }
}
