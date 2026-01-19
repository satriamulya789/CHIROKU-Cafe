import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/views/admin_report_top_product_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_product_list_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_section_header_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopProductsSection extends StatelessWidget {
  final ReportAdminController controller;
  const TopProductsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.emoji_events,
          title: 'Top 5 Best-selling Menus',
          subtitle: 'Based on quantity sold',
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
            child: Column(
              children: [
                ProductListWidget(products: controller.top5Products),
                if (controller.productStats.length > 5) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => TopProductsView(
                            products: controller.top20Products,
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        'View Top 20 Menus',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brownNormal,
                        side: BorderSide(color: AppColors.brownNormal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

