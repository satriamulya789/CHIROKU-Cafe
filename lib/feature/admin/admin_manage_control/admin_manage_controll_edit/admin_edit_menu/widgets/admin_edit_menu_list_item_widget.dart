import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuListItem extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuListItem({
    super.key,
    required this.menu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.brownDarkActive.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: menu.imageUrl != null
              ? Image.network(
                  menu.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: AppColors.brownLight,
                      child: const Icon(Icons.fastfood, color: AppColors.brownDarkActive),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColors.brownLight,
                  child: const Icon(Icons.fastfood, color: AppColors.brownDarkActive),
                ),
        ),
        title: Text(
          menu.name,
          style: AppTypography.h6.copyWith(
            color: AppColors.brownDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(menu.price),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.brownNormal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: menu.isAvailable 
                        ? AppColors.successLight 
                        : AppColors.alertLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    menu.isAvailable ? 'Available' : 'Not Available',
                    style: AppTypography.label.copyWith(
                      color: menu.isAvailable 
                          ? AppColors.successNormal 
                          : AppColors.alertNormal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${menu.stock}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
              ],
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