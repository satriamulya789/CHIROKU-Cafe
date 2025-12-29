import 'package:chiroku_cafe/configs/themes/theme.dart';
import 'package:chiroku_cafe/shared/repositories/order/order_service.dart';
import 'package:flutter/material.dart';

class CancelOrderDialog extends StatefulWidget {
  final int orderId;
  final String customerName;
  final VoidCallback? onCancelled;

  const CancelOrderDialog({
    Key? key,
    required this.orderId,
    required this.customerName,
    this.onCancelled,
  }) : super(key: key);

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _predefinedReasons = [
    'Customer request',
    'Out of stock',
    'Kitchen issue',
    'Payment problem',
    'Wrong order',
    'Other',
  ];
  String? _selectedReason;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.brownNormal),
          const SizedBox(width: 8),
          Text(
            'Cancel Order',
            style: TextStyle(
              color: AppColors.brownDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this order?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.brownDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brownLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brownLightActive, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.orderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brownDark,
                    ),
                  ),
                  Text(
                    'Customer: ${widget.customerName}',
                    style: TextStyle(color: AppColors.brownDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cancellation Reason:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.brownDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.brownNormalHover),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.brownLightActive),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.brownNormal,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Select reason',
                hintStyle: TextStyle(color: AppColors.brownNormalHover),
                filled: true,
                fillColor: AppColors.white,
              ),
              items: _predefinedReasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(
                    reason,
                    style: TextStyle(color: AppColors.brownDark),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              dropdownColor: AppColors.white,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.brownNormalHover),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.brownLightActive),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.brownNormal,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Additional Notes (Optional)',
                labelStyle: TextStyle(color: AppColors.brownNormalHover),
                hintText: 'Enter additional details...',
                hintStyle: TextStyle(color: AppColors.brownNormalHover),
                filled: true,
                fillColor: AppColors.white,
              ),
              style: TextStyle(color: AppColors.brownDark),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.brownDark),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCancelOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brownDark,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.brownLightActive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Text('Cancel Order'),
        ),
      ],
    );
  }

  void _handleCancelOrder() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a cancellation reason'),
          backgroundColor: AppColors.brownNormal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderService = OrderService();

      String finalReason = _selectedReason!;
      if (_reasonController.text.isNotEmpty) {
        finalReason += ' - ${_reasonController.text}';
      }

      final success = await orderService.cancelOrder(
        orderId: widget.orderId,
        reason: finalReason,
      );

      if (!mounted) return;

      if (success) {
        // Close dialog first
        Navigator.of(context).pop(true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: AppColors.brownNormal,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Call the callback
        widget.onCancelled?.call();
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.brownDark,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

// Helper function to show the dialog
Future<bool?> showCancelOrderDialog({
  required BuildContext context,
  required int orderId,
  required String customerName,
  VoidCallback? onCancelled,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CancelOrderDialog(
      orderId: orderId,
      customerName: customerName,
      onCancelled: onCancelled,
    ),
  );
}
