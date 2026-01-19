import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class TransactionDateFilterSection extends StatelessWidget {
  final String selectedFilter;
  final DateTimeRange? customDateRange;
  final Function(String) onFilterSelected;
  final Future<void> Function() onCustomDateRangeTap;

  const TransactionDateFilterSection({
    super.key,
    required this.selectedFilter,
    required this.customDateRange,
    required this.onFilterSelected,
    required this.onCustomDateRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Date Filter',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(context, 'Today', 'today'),
            _buildFilterChip(context, 'Last 7 Days', 'week'),
            _buildFilterChip(context, 'This Month', 'month'),
            _buildFilterChip(context, 'All Time', 'all'),
            FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    selectedFilter == 'custom' && customDateRange != null
                        ? '${DateFormat('dd/MM').format(customDateRange!.start)} - ${DateFormat('dd/MM').format(customDateRange!.end)}'
                        : 'Custom',
                    style: TextStyle(
                      color: selectedFilter == 'custom'
                          ? Colors.white
                          : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              selected: selectedFilter == 'custom',
              onSelected: (selected) => onCustomDateRangeTap(),
              selectedColor: AppColors.brownNormal,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.brownLight,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterSelected(value);
        }
      },
      selectedColor: AppColors.brownNormal,
      checkmarkColor: Colors.white,
      backgroundColor: AppColors.brownLight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class DateRangeButtonWidget extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const DateRangeButtonWidget({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        date == null ? label : '$label: ${_formatDate(date!)}',
        style: AppTypography.bodyMedium,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

Future<DateTimeRange?> showDateRangePopup(BuildContext context, DateTimeRange? initialRange) async {
  DateTime? start = initialRange?.start;
  DateTime? end = initialRange?.end;

  return showDialog<DateTimeRange>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateRangeButtonWidget(
                label: 'Start Date',
                date: start,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: end ?? DateTime.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.brownNormal,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.brownDarker,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      start = picked;
                      if (end != null && end!.isBefore(start!)) end = start;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DateRangeButtonWidget(
                label: 'End Date',
                date: end,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: end ?? (start ?? DateTime.now()),
                    firstDate: start ?? DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.brownNormal,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.brownDarker,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      end = picked;
                      if (start != null && end!.isBefore(start!)) start = end;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brownNormal,
              ),
              onPressed: (start != null && end != null)
                  ? () => Navigator.pop(context, DateTimeRange(start: start!, end: end!))
                  : null,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}