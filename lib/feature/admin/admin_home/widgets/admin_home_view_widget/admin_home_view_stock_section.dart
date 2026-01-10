import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_stock_status_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockSectionWidget extends StatelessWidget {
  final List<StockStatusModel> stocks;

  const StockSectionWidget({
    super.key,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.brownNormal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stock Status',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.brownDarker,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.adminManageControl),
                child: Text(
                  'Manage Stock',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stocks.map((stock) => StockStatusWidget(stock: stock)),
        ],
      ),
    );
  }
}