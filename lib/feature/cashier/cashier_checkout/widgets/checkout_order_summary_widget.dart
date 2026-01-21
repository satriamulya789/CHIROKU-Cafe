import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutOrderSummaryWidget extends StatelessWidget {
  final List<CartItemModel> cartItems;

  const CheckoutOrderSummaryWidget({super.key, required this.cartItems});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.brownNormal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cartItems.map((item) => _buildOrderItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fastfood, color: AppColors.greyNormal),
                ),
              ),
            ),
          if (item.imageUrl != null) const SizedBox(width: 12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTypography.bodyMediumBold.copyWith(
                    color: AppColors.brownDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatCurrency(item.price)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyNormalActive,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${item.note}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.greyNormalHover,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Price
          Text(
            _formatCurrency(item.total),
            style: AppTypography.bodyMediumBold.copyWith(
              color: AppColors.brownNormal,
            ),
          ),
        ],
      ),
    );
  }
}
