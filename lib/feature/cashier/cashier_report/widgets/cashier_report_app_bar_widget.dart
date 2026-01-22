import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class CashierReportAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onExportTap;

  const CashierReportAppBar({super.key, this.onExportTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brownLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.brownNormal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.bar_chart_outlined,
                  color: AppColors.brownNormal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashier Report',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.brownDarker,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Summary & Recent Orders',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brownNormal.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onExportTap != null)
                IconButton(
                  onPressed: onExportTap,
                  icon: const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.brownNormal,
                  ),
                  tooltip: 'Export to Excel',
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}
