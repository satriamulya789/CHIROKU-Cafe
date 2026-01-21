import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutPriceSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double serviceFee;
  final double tax;
  final double discount;
  final double total;
  final String? discountName;

  const CheckoutPriceSummaryWidget({
    super.key,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    this.discount = 0.0,
    required this.total,
    this.discountName,
  });

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
                Icon(Icons.calculate, color: AppColors.brownNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Price Summary',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Subtotal', subtotal),
            _buildPriceRow('Service Fee (5%)', serviceFee),
            _buildPriceRow('Tax (10%)', tax),
            if (discount > 0) ...[
              _buildPriceRow(
                discountName != null ? 'Discount ($discountName)' : 'Discount',
                -discount,
                isDiscount: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(thickness: 1.5),
            ),
            _buildPriceRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.bodyLargeBold.copyWith(
                    color: AppColors.brownDark,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.greyNormalActive,
                  ),
          ),
          Text(
            _formatCurrency(amount),
            style: isTotal
                ? AppTypography.priceMedium.copyWith(
                    color: AppColors.brownNormal,
                  )
                : AppTypography.bodyMediumBold.copyWith(
                    color: isDiscount
                        ? AppColors.successNormal
                        : AppColors.brownDark,
                  ),
          ),
        ],
      ),
    );
  }
}
