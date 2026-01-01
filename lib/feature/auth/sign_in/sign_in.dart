import 'package:chiroku_cafe/feature/auth/sign_in/controllers/sign_in_controller.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/button_sign_in.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/email_text_field.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/widgets/password_text_field.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/divider.dart';
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
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Text
                Text(
                  'Sign in to your\nAccount',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'Enter your email and password to log in',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                const SizedBox(height: 32),

                // Text Input Controller
                EmailTextField(controller: controller.emailController),

                const SizedBox(height: 18),
                PasswordTextField(
                  controller: controller.passwordController,
                  isHidden: controller.isPasswordHidden,
                ),

                SizedBox(height: 30,),
                AuthButton(
                  label: 'Sign In',
                  onPressed: controller.signIn,
                  isLoading: controller.isLoading, model: null,
                ),

                SizedBox(height: 40),
                DivenderWidget()


  




                // // Sign In Button with StateMixin
                // controller.obx(
                //   (state) => _buildSignInButton(controller, isLoading: false),
                //   onLoading: _buildSignInButton(controller, isLoading: true),
                //   onError: (error) => Column(
                //     children: [
                //       _buildSignInButton(controller, isLoading: false),
                //     ],
                //   ),
                //   onEmpty: _buildSignInButton(controller, isLoading: false),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildSignInButton(SignInController controller, {required bool isLoading}) {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 52,
  //     child: ElevatedButton(
  //       onPressed: isLoading ? null : () => controller.signIn(),
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: AppColors.brownNormal,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         disabledBackgroundColor: AppColors.brownLight,
  //       ),
  //       child: isLoading
  //           ? const SizedBox(
  //               height: 24,
  //               width: 24,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2.5,
  //                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
  //               ),
  //             )
  //           : Text(
  //               'Sign In',
  //               style: AppTypography.buttonLarge.copyWith(
  //                 color: AppColors.white,
  //               ),
  //             ),
  //     ),
  //   );
  // }
}