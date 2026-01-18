import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class StockStatusWidget extends StatelessWidget {
  final StockStatusModel stock;

  const StockStatusWidget({super.key, required this.stock});

  Color _getStatusColor() {
    switch (stock.status) {
      case 'Ready':
        return AppColors.successNormal;
      case 'Low Stock':
        return AppColors.warningNormal;
      case 'Out of Stock':
        return AppColors.alertNormal;
      default:
        return AppColors.brownNormal;
    }
  }

  IconData _getStatusIcon() {
    switch (stock.status) {
      case 'Ready':
        return Icons.check_circle;
      case 'Low Stock':
        return Icons.warning;
      case 'Out of Stock':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brownLight, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brownLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.restaurant_menu,
                color: AppColors.brownDarkActive, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.productName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  stock.category,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stock.currentStock} units',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Icon(_getStatusIcon(), size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    stock.status,
                    style: AppTypography.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}