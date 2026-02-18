import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/widgets/admin_edit_table_form_dialog.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/widgets/admin_edit_table_list_item.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditTableView extends GetView<AdminEditTableController> {
  const AdminEditTableView({super.key});

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

              if (controller.filteredTables.isEmpty) {
                return Center(
                  child: Text(
                    'No tables found',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.brownDark,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.syncNow,
                color: AppColors.brownNormal,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredTables.length,
                  itemBuilder: (context, index) {
                    final table = controller.filteredTables[index];
                    return TableListItem(
                      table: table,
                      onEdit: () => _showEditDialog(context, table),
                      onDelete: () => _showDeleteDialog(context, table.id!),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_edit_table_fab',
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.brownNormal,
        icon: const Icon(Icons.table_chart, color: AppColors.white),
        label: Text(
          'Add Table',
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
          hintText: 'Search tables...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.brownNormal.withValues(alpha: 0.5),
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
      builder: (context) => const TableFormDialog(isEdit: false),
    );
  }

  void _showEditDialog(BuildContext context, table) {
    controller.setEditTable(table);
    showDialog(
      context: context,
      builder: (context) => TableFormDialog(tableId: table.id, isEdit: true),
    );
  }

  void _showDeleteDialog(BuildContext context, int tableId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Table', style: AppTypography.h5),
        content: Text(
          'Are you sure you want to delete this table?',
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
              controller.deleteTable(tableId);
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
