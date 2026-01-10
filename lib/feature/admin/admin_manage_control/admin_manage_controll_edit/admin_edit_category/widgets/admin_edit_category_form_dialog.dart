import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryFormDialog extends GetView<AdminEditCategoryController> {
  final int? categoryId;
  final bool isEdit;

  const CategoryFormDialog({
    super.key,
    this.categoryId,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Category' : 'Add Category',
        style: AppTypography.h5,
      ),
      content: TextField(
        controller: controller.nameController,
        decoration: InputDecoration(
          labelText: 'Category Name',
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
        autofocus: true,
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
              : () => isEdit 
                  ? controller.updateCategory(categoryId!) 
                  : controller.createCategory(),
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