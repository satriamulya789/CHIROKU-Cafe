import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CheckoutCashInputWidget extends StatelessWidget {
  final TextEditingController cashController;
  final double total;
  final double changeAmount;
  final bool isCashValid;

  const CheckoutCashInputWidget({
    super.key,
    required this.cashController,
    required this.total,
    required this.changeAmount,
    required this.isCashValid,
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
                Icon(Icons.money, color: AppColors.successNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cash Payment',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total to pay
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brownLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payment',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.brownDark,
                    ),
                  ),
                  Text(
                    _formatCurrency(total),
                    style: AppTypography.priceMedium.copyWith(
                      color: AppColors.brownNormal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cash input
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.input,
              decoration: InputDecoration(
                labelText: 'Enter Cash Amount',
                labelStyle: AppTypography.labelLarge.copyWith(
                  color: AppColors.greyNormalActive,
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: AppColors.successNormal,
                ),
                prefixText: 'Rp ',
                prefixStyle: AppTypography.input.copyWith(
                  color: AppColors.brownDark,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.greyLightActive),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.greyLightActive),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.brownNormal,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.alertNormal),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.alertNormal,
                    width: 2,
                  ),
                ),
                errorText: !isCashValid && cashController.text.isNotEmpty
                    ? 'Insufficient cash amount'
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // Change amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: changeAmount >= 0 && cashController.text.isNotEmpty
                    ? AppColors.successLight
                    : AppColors.alertLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: changeAmount >= 0 && cashController.text.isNotEmpty
                      ? AppColors.successNormal
                      : AppColors.alertNormal,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    changeAmount >= 0 ? 'Change' : 'Remaining',
                    style: AppTypography.bodyMediumBold.copyWith(
                      color: changeAmount >= 0 && cashController.text.isNotEmpty
                          ? AppColors.successDark
                          : AppColors.alertDark,
                    ),
                  ),
                  Text(
                    _formatCurrency(changeAmount.abs()),
                    style: AppTypography.priceMedium.copyWith(
                      color: changeAmount >= 0 && cashController.text.isNotEmpty
                          ? AppColors.successNormal
                          : AppColors.alertNormal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quick amount buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickAmountButton(context, 50000),
                _buildQuickAmountButton(context, 100000),
                _buildQuickAmountButton(context, 150000),
                _buildQuickAmountButton(context, 200000),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(BuildContext context, int amount) {
    return OutlinedButton(
      onPressed: () {
        cashController.text = amount.toString();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.brownNormal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        _formatCurrency(amount.toDouble()),
        style: AppTypography.buttonSmall.copyWith(color: AppColors.brownNormal),
      ),
    );
  }
}
