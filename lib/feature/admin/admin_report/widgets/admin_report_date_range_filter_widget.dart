import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilterWidget extends StatelessWidget {
  final ReportAdminController controller;
  const DateRangeFilterWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.brownNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filter Period',
                  style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDateRange(context, controller),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: AppColors.brownNormal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.dateRange != null
                            ? '${DateFormat('dd MMM yyyy').format(controller.dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(controller.dateRange!.end)}'
                            : 'Today',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppColors.brownNormal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 Future<void> _selectDateRange(BuildContext context, ReportAdminController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.brownNormal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.brownDarker,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brownNormal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

