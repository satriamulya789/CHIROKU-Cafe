import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountListWidget extends StatelessWidget {
  final List<DiscountModel> discounts;
  final void Function(DiscountModel discount)? onEdit;
  final void Function(int id)? onDelete;

  const DiscountListWidget({
    super.key,
    required this.discounts,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (discounts.isEmpty) {
      return const Center(child: Text('No discounts yet'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: discounts.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final d = discounts[i];
        return ListTile(
          leading: Icon(
            d.type == 'fixed' ? Icons.money : Icons.percent,
            color: AppColors.brownNormal,
          ),
          title: Text(d.name, style: AppTypography.bodyMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.type == 'fixed'
                  ? 'Amount: Rp ${d.value.toStringAsFixed(0)}'
                  : 'Percent: ${d.value.toStringAsFixed(0)}%',
                style: AppTypography.bodySmall,
              ),
              Text(
                'Start: ${_formatDate(d.startDate)}  |  End: ${_formatDate(d.endDate)}',
                style: AppTypography.bodySmall.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.brownNormal),
                onPressed: () => onEdit?.call(d),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: AppColors.alertNormal),
                onPressed: () {
                  if (d.id != null) onDelete?.call(d.id!);
                },
              ),
              d.isActive
                  ? const Icon(Icons.check_circle, color: AppColors.successNormal)
                  : const Icon(Icons.cancel, color: AppColors.alertNormal),
            ],
          ),
        );
      },
    );
  }
}