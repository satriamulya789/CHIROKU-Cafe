import 'package:chiroku_cafe/feature/cashier/cashier_edit_profile/controllers/cashier_edit_profile_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_edit_profile/widgets/cashier_edit_profile_avatar_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_text_field.dart';
import 'package:chiroku_cafe/utils/enums/text_field_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashierEditProfileView extends GetView<CashierEditProfileController> {
  const CashierEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brownDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.userProfile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brownNormal),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Obx(
                  () => CashierAvatarPickerWidget(
                    avatarUrl: controller.userProfile.value?.avatarUrl,
                    selectedImage: controller.selectedImage.value,
                    isLoading: controller.isUploadingImage.value,
                    onTap: controller.showImageSourceDialog,
                  ),
                ),
                const SizedBox(height: 40),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildFormSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.blueNormal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.blueNormal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Role cannot be changed. Contact administrator if you need to change your role.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.blueDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: AppTypography.h6.copyWith(
              color: AppColors.brownDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            controller: controller.fullNameController,
            type: TextFieldType.name,
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: controller.emailController,
            type: TextFieldType.email,
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: 16),
          _buildRoleField(),
        ],
      ),
    );
  }

  Widget _buildRoleField() {
    return Obx(() {
      final role = controller.userProfile.value?.role ?? 'cashier';
      final roleDisplay =
          role.substring(0, 1).toUpperCase() + role.substring(1);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role',
            style: AppTypography.label.copyWith(color: AppColors.brownDark),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.brownLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.brownNormal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                  color: AppColors.brownNormal.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  roleDisplay,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brownNormal.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.lock,
                  color: AppColors.brownNormal.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brownNormal,
            disabledBackgroundColor: AppColors.brownNormal.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save Changes',
                  style: AppTypography.button.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
