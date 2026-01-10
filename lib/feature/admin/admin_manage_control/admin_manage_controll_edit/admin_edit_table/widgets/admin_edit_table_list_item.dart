import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class TableListItem extends StatelessWidget {
  final TableModel table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TableListItem({
    super.key,
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: table.status == 'available' 
                ? AppColors.successLight 
                : AppColors.warningLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.table_restaurant,
            color: table.status == 'available' 
                ? AppColors.successNormal 
                : AppColors.warningNormal,
          ),
        ),
        title: Text(
          table.tableName,
          style: AppTypography.h6.copyWith(
            color: AppColors.brownDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: AppColors.brownNormal,
                ),
                const SizedBox(width: 4),
                Text(
                  'Capacity: ${table.capacity}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: table.status == 'available' 
                    ? AppColors.successLight 
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                table.status.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: table.status == 'available' 
                      ? AppColors.successNormal 
                      : AppColors.warningNormal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.blueNormal),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.alertNormal),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}