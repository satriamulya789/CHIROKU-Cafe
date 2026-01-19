import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserFormDialog extends GetView<AdminEditUserController> {
  final String userId;
  final bool isEdit;

  const UserFormDialog({
    super.key,
    required this.userId,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit ? 'Edit User' : 'Add User',
        style: AppTypography.h5,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.brownNormal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brownNormal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.brownNormal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brownNormal),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password input hanya untuk Add User
            if (!isEdit) ...[
              Obx(() {
                return TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordObscured.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.brownNormal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.brownNormal),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordObscured.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.brownNormal,
                      ),
                      onPressed: () {
                        controller.isPasswordObscured.value =
                            !controller.isPasswordObscured.value;
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                return TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.isConfirmPasswordObscured.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.brownNormal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.brownNormal),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordObscured.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.brownNormal,
                      ),
                      onPressed: () {
                        controller.isConfirmPasswordObscured.value =
                            !controller.isConfirmPasswordObscured.value;
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: controller.roleController.text.isEmpty 
                  ? 'cashier' 
                  : controller.roleController.text,
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.brownNormal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brownNormal),
                ),
              ),
              items: ['admin', 'cashier'].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase(), style: AppTypography.bodyMedium),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.roleController.text = value;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(
              color: AppColors.brownNormal,
            ),
          ),
        ),
        Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (isEdit) {
                    controller.updateUser(userId);
                  } else {
                    controller.createUser();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brownNormal,
            disabledBackgroundColor: AppColors.brownNormal.withOpacity(0.5),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  isEdit ? 'Update' : 'Add',
                  style: AppTypography.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
        )),
      ],
    );
  }
}