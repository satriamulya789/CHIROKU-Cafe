import 'package:chiroku_cafe/feature/cashier/cashier_report/controllers/cashier_report_controller.dart';
import 'package:chiroku_cafe/shared/widgets/report/report_section_header_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/widgets/report/report_product_list_widget.dart';
import 'package:flutter/material.dart';

class CashierTopProductsSection extends StatelessWidget {
  final ReportCashierController controller;
  const CashierTopProductsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.top5Products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReportSectionHeader(
          icon: Icons.trending_up,
          title: 'Top 5 Menus',
          subtitle: 'Best selling items by quantity',
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ProductListWidget(
              products: controller.top5Products.toList(),
            ),
          ),
        ),
      ],
    );
  }
}
