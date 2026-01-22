import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/widgets/admin_edit_user_form_dialog.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/widgets/admin_edit_user_list_item.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditUserView extends GetView<AdminEditUserController> {
  const AdminEditUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brownNormal,
                  ),
                );
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: AppColors.brownNormal.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.brownDark,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchUsers,
                color: AppColors.brownNormal,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return UserListItem(
                      user: user,
                      onEdit: () => _showEditDialog(context, user),
                      onDelete: () => _showDeleteDialog(context, user),
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
        icon: const Icon(Icons.person_add, color: AppColors.white),
        label: Text(
          'Add User',
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
          hintText: 'Search users...',
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
      builder: (context) => const UserFormDialog(isEdit: false, userId: ''),
    );
  }

  void _showEditDialog(BuildContext context, user) {
    controller.setEditUser(user);
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(userId: user.id, isEdit: true),
    );
  }

  void _showDeleteDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User', style: AppTypography.h5),
        content: Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
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
              controller.deleteUser(user);
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
