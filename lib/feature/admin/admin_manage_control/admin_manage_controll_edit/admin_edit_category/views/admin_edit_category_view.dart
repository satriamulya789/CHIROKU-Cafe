import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/widgets/admin_edit_category_form_dialog.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/widgets/admin_edit_category_list_item.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditCategoryView extends GetView<AdminEditCategoryController> {
  const AdminEditCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brownNormal,
                  ),
                );
              }

              if (controller.filteredCategories.isEmpty) {
                return Center(
                  child: Text(
                    'No categories found',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.brownDark,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshCategories,
                color: AppColors.brownNormal,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = controller.filteredCategories[index];
                    return CategoryListItem(
                      category: category,
                      onEdit: () => _showEditDialog(context, category),
                      onDelete: () => _showDeleteDialog(context, category.id!),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.brownNormal,
        icon: const Icon(Icons.category, color: AppColors.white),
        label: Text(
          'Add Category',
          style: AppTypography.button.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.brownNormal.withOpacity(0.5),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.brownNormal),
          filled: true,
          fillColor: AppColors.brownLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    controller.clearForm();
    showDialog(
      context: context,
      builder: (context) => const CategoryFormDialog(isEdit: false),
    );
  }

  void _showEditDialog(BuildContext context, CategoryModel category) {
    controller.setEditCategory(category);
    showDialog(
      context: context,
      builder: (context) =>
          CategoryFormDialog(categoryId: category.id!, isEdit: true),
    );
  }

  void _showDeleteDialog(BuildContext context, int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category', style: AppTypography.h5),
        content: Text(
          'Are you sure you want to delete this category?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(
                color: AppColors.brownNormal,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCategory(categoryId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertNormal,
            ),
            child: Text(
              'Delete',
              style: AppTypography.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
