import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_report/repositories/cashier_report_repositories.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetailDialog extends StatefulWidget {
  final ReportTransaction transaction;

  const ReportDetailDialog({super.key, required this.transaction});

  @override
  State<ReportDetailDialog> createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends State<ReportDetailDialog> {
  final repo = ReportCashierRepository();
  Map<String, dynamic>? orderDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await repo.getOrderDetail(widget.transaction.id);
      setState(() {
        orderDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.brownDarker,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 32),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (orderDetail == null)
              const Center(child: Text('Failed to load details'))
            else ...[
              _buildInfoRow('Order ID', '#${widget.transaction.id}'),
              _buildInfoRow('Customer', widget.transaction.customerName ?? '-'),
              _buildInfoRow('Table', widget.transaction.tableName ?? '-'),
              _buildInfoRow(
                'Status',
                widget.transaction.orderStatus.toUpperCase(),
                color: widget.transaction.orderStatus == 'pending'
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Items',
                style: AppTypography.bodyMediumBold.copyWith(
                  color: AppColors.brownDarker,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (orderDetail!['order_items'] as List).length,
                  itemBuilder: (context, index) {
                    final item = orderDetail!['order_items'][index];
                    final menu = item['menu'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['qty']}x ${menu['name']}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          Text(
                            currencyFormat.format(item['total']),
                            style: AppTypography.bodySmallBold,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTypography.bodyLargeBold.copyWith(
                      color: AppColors.brownDarker,
                    ),
                  ),
                  Text(
                    currencyFormat.format(widget.transaction.total),
                    style: AppTypography.bodyLargeBold.copyWith(
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: AppTypography.bodySmallBold.copyWith(
              color: color ?? AppColors.brownDarker,
            ),
          ),
        ],
      ),
    );
  }
}
