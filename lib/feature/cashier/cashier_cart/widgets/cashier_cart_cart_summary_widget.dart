import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartSummaryWidget extends StatelessWidget {
  final CartController controller;

  const CartSummaryWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Note Field
          TextField(
            onChanged: (value) => controller.setOrderNote(value),
            decoration: InputDecoration(
              labelText: 'Order Notes (Optional)',
              labelStyle: AppTypography.labelLarge.copyWith(
                color: AppColors.greyNormalHover,
              ),
              hintText: 'Add special instructions...',
              hintStyle: AppTypography.inputHint.copyWith(
                color: AppColors.greyNormal,
              ),
              prefixIcon: const Icon(
                Icons.note_outlined,
                color: AppColors.brownNormal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyNormal),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.brownNormal,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
            style: AppTypography.input,
          ),
          const SizedBox(height: 16),

          const Divider(height: 24),

          // Price Breakdown
          Obx(
            () => Column(
              children: [
                _buildPriceRow('Subtotal', controller.subtotal),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showDiscountDialog(context, controller),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Discount',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.greyDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.orangeNormal),
                            ),
                            child: Text(
                              controller.selectedDiscount.value?.displayText ??
                                  '0%',
                              style: AppTypography.badge.copyWith(
                                color: AppColors.orangeDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.greyNormalHover,
                          ),
                        ],
                      ),
                      Text(
                        '- ${_formatCurrency(controller.discountAmount)}',
                        style: AppTypography.bodyMediumBold.copyWith(
                          color: AppColors.orangeDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriceRow('Tax (10%)', controller.taxAmount),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.brownDark,
                      ),
                    ),
                    Text(
                      _formatCurrency(controller.total),
                      style: AppTypography.priceMedium.copyWith(
                        color: AppColors.brownNormal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkout Button
          ElevatedButton(
            onPressed: () => _processCheckout(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, color: AppColors.white),
                const SizedBox(width: 8),
                Text(
                  'Process Order',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.greyDark),
        ),
        Text(
          _formatCurrency(amount),
          style: AppTypography.bodyMediumBold.copyWith(
            color: AppColors.brownDark,
          ),
        ),
      ],
    );
  }

  void _showDiscountDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Discount',
          style: AppTypography.h5.copyWith(color: AppColors.brownDark),
        ),
        content: Obx(() {
          if (controller.isLoadingDiscounts.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.brownNormal),
              ),
            );
          }

          if (controller.availableDiscounts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No discounts available',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.greyNormalHover,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDiscountOption(controller, null, 'No Discount'),
                ...controller.availableDiscounts.map(
                  (discount) => _buildDiscountOption(
                    controller,
                    discount,
                    '${discount.name} (${discount.displayText})',
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDiscountOption(
    CartController controller,
    dynamic discount,
    String label,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.bodyMedium),
      leading: Radio<dynamic>(
        value: discount,
        groupValue: controller.selectedDiscount.value,
        activeColor: AppColors.brownNormal,
        onChanged: (value) {
          controller.setDiscount(value);
          Get.back();
        },
      ),
    );
  }

  void _processCheckout(BuildContext context, CartController controller) {
    // Navigate to checkout page
    Get.toNamed('/cashier/checkout');
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
