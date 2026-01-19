import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_cashier_peformance_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/widgets/admin_report_section_header_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';

class CashierPerformanceSection extends StatelessWidget {
  final ReportAdminController controller;
  const CashierPerformanceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.people,
          title: 'Cashier Performance',
          subtitle: 'Top cashiers by revenue & orders',
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
            child: CashierPerformanceWidget(
              cashiers: controller.cashierStats,
            ),
          ),
        ),
      ],
    );
  }
}