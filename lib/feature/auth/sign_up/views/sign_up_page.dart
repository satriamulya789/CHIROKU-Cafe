import 'package:chiroku_cafe/feature/sign_in/widgets/email_text_field.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/controllers/sign_up_controller.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/widgets/already_have_acc.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/widgets/button_sign_up.dart';
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
                SizedBox(height: 12),
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
                SizedBox(height: 32),

                //Full Name Text Field
                CustomTextField(
                  label: 'Name',
                  hintText: 'Enter your  name',
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  type: TextFieldType.name,
                ),

                //Email Text Field
                SizedBox(height: 16),
                CustomTextField(
              label: 'Email Address',
              hintText: 'Enter your email address',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              type: TextFieldType.email,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: controller.passwordController,
              obscureText: controller.isPasswordObscured.value,
              type: TextFieldType.password,
              
            ),
            SizedBox(height: 24),

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
