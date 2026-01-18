import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/views/admin_edit_menu_form_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/widgets/admin_edit_menu_list_item_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditMenuView extends GetView<AdminEditMenuController> {
  const AdminEditMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.menus.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brownDarkActive,
                  ),
                );
              }

              if (controller.filteredMenus.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 80,
                        color: AppColors.brownDarkActive.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No menus found',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.brownDark,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchMenus,
                color: AppColors.brownDark,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredMenus.length,
                  itemBuilder: (context, index) {
                    final menu = controller.filteredMenus[index];
                    return MenuListItem(
                      menu: menu,
                      onEdit: () => _navigateToEditPage(menu),
                      onDelete: () => _showDeleteDialog(context, menu.id, menu.imageUrl),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPage,
        backgroundColor: AppColors.brownNormal,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Add Menu',
          style: AppTypography.button.copyWith(
            color: AppColors.white,
          ),
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
          hintText: 'Search menus...',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _navigateToAddPage() {
    controller.clearForm();
    Get.to(
      () => const AdminMenuFormPage(isEdit: false),
      transition: Transition.rightToLeft,
    );
  }

  void _navigateToEditPage(menu) {
    controller.setEditMenu(menu);
    Get.to(
      () => AdminMenuFormPage(menuId: menu.id, isEdit: true),
      transition: Transition.rightToLeft,
    );
  }

  void _showDeleteDialog(BuildContext context, int menuId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Menu', style: AppTypography.h5),
        content: Text(
          'Are you sure you want to delete this menu? This action cannot be undone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: AppTypography.button.copyWith(
                  color: AppColors.brownNormal,
                )),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMenu(menuId, imageUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertNormal,
            ),
            child: Text('Delete',
                style: AppTypography.button.copyWith(
                  color: AppColors.white,
                )),
          ),
        ],
      ),
    );
  }
}