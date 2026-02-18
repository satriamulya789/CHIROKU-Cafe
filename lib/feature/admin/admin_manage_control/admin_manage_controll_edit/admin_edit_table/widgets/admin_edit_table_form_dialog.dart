import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableFormDialog extends GetView<AdminEditTableController> {
  final int? tableId;
  final bool isEdit;

  const TableFormDialog({super.key, this.tableId, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Edit Table' : 'Add Table', style: AppTypography.h5),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.tableNameController,
              decoration: _inputDecoration('Table Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.capacityController,
              decoration: _inputDecoration('Capacity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedStatus.value,
                decoration: _inputDecoration('Status'),
                items: ['available', 'reserved'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.toUpperCase(),
                      style: AppTypography.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedStatus.value = value;
                  }
                },
              ),
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
            style: AppTypography.button.copyWith(color: AppColors.brownNormal),
          ),
        ),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => isEdit
                      ? controller.updateTable(tableId!)
                      : controller.createTable(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
              disabledBackgroundColor: AppColors.brownNormal.withValues(
                alpha: 0.5,
              ),
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
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.brownNormal,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brownNormal),
      ),
    );
  }
}
