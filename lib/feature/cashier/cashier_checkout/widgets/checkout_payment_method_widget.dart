import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class CheckoutPaymentMethodWidget extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;
  final bool hasQrisUrl;

  const CheckoutPaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    this.hasQrisUrl = false,
  });

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
                Icon(Icons.payment, color: AppColors.brownNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              value: 'cash',
              title: 'Cash',
              subtitle: 'Pay with cash',
              icon: Icons.money,
              color: AppColors.successNormal,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              value: 'qris',
              title: 'QRIS',
              subtitle: hasQrisUrl
                  ? 'Scan QR code for payment'
                  : 'QRIS not configured',
              icon: Icons.qr_code_scanner,
              color: AppColors.purpleNormal,
              isEnabled: hasQrisUrl,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              value: 'card',
              title: 'Debit/Credit Card',
              subtitle: 'Pay with card',
              icon: Icons.credit_card,
              color: AppColors.blueNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isEnabled = true,
  }) {
    final isSelected = selectedMethod == value;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: isEnabled ? () => onMethodSelected(value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppColors.greyLightActive,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? color.withOpacity(0.05) : AppColors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMediumBold.copyWith(
                        color: isSelected ? color : AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.greyNormalActive,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
