// lib/feature/admin/admin_report/views/top_products_view.dart

import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_product_list_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class TopProductsView extends StatelessWidget {
  final List<ReportProductStat> products;

  const TopProductsView({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        title: Text(
          'Top 20 Menu Terlaris',
          style: AppTypography.h4.copyWith(color: AppColors.brownDarker),
        ),
        backgroundColor: AppColors.brownLight,
        elevation: 0,
        foregroundColor: AppColors.brownDarker,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ProductListWidget(products: products),
            ),
          ),
        ],
      ),
    );
  }
}