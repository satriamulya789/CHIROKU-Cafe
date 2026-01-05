import 'package:chiroku_cafe/feature/auth/complete_profile/controllers/complete_profile_controller.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/widget/avatar_picker_widget.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/widget/complete_profile_button.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompleteProfileController>();
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
            key: controller.nameFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Let\'s create something amazing together',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                const SizedBox(height: 40),

                //Avatar Profile
                Obx(() {
                  return AvatarPickerWidget(
                    avatarFile: controller.avatarFile,
                    isUploading: controller.isUploading,
                    onTap: controller.selectImageSource,
                    onRemove: controller.removeAvatar,
                  );
                }),

                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Name',
                  hintText: 'Enter your name',
                  controller: controller.nameController,
                  type: TextFieldType.name,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

                CompleteProfileButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
