import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class CheckoutQrisWidget extends StatelessWidget {
  final String qrisUrl;

  const CheckoutQrisWidget({super.key, required this.qrisUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.purpleNormal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scan QRIS',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QRIS Image
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purpleNormal, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  qrisUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.purpleNormal,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.alertNormal,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load QR Code',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.alertDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Instructions:',
                    style: AppTypography.bodyMediumBold.copyWith(
                      color: AppColors.purpleDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstruction(
                    '1. Open your e-wallet or mobile banking app',
                  ),
                  _buildInstruction('2. Select Scan QR or QRIS menu'),
                  _buildInstruction('3. Scan the QR Code above'),
                  _buildInstruction('4. Confirm the payment'),
                  _buildInstruction(
                    '5. Click "Process Payment" button after success',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.purpleNormal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.purpleDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
