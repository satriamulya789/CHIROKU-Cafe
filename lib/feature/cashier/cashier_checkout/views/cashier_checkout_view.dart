import 'package:chiroku_cafe/feature/cashier/cashier_checkout/controllers/cashier_checkout_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/widgets/checkout_cash_input_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/widgets/checkout_order_summary_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/widgets/checkout_payment_method_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/widgets/checkout_price_summary_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_checkout/widgets/checkout_qris_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: AppTypography.appBarTitle.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.brownNormal,
        foregroundColor: AppColors.white,
      ),
      body: Obx(() {
        // Check if cart is empty
        if (controller.cartController.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              CheckoutOrderSummaryWidget(
                cartItems: controller.cartController.cartItems,
              ),
              const SizedBox(height: 16),

              // Table Selection
              _buildTableSelection(),
              const SizedBox(height: 16),

              // Customer Name
              _buildCustomerNameInput(),
              const SizedBox(height: 16),

              // Discount Info (if applied)
              if (controller.cartController.selectedDiscount.value != null)
                _buildDiscountInfo(),
              if (controller.cartController.selectedDiscount.value != null)
                const SizedBox(height: 16),

              // Payment Method
              CheckoutPaymentMethodWidget(
                selectedMethod: controller.paymentMethod.value,
                onMethodSelected: controller.setPaymentMethod,
                hasQrisUrl:
                    controller.paymentSettings.value?.hasQrisUrl ?? false,
              ),
              const SizedBox(height: 16),

              // Cash Input (if cash payment)
              CheckoutCashInputWidget(
                cashController: controller.cashController,
                total: controller.total,
                changeAmount: controller.changeAmount.value,
                isCashValid: controller.isCashValid.value,
                onExactChange: controller.setExactChange,
                onAddCash: controller.addCash,
              ),
              if (controller.paymentMethod.value == 'cash')
                const SizedBox(height: 16),

              // QRIS (if QRIS payment)
              if (controller.paymentMethod.value == 'qris' &&
                  controller.paymentSettings.value?.hasQrisUrl == true)
                CheckoutQrisWidget(
                  qrisUrl: controller.paymentSettings.value!.qrisUrl!,
                ),
              if (controller.paymentMethod.value == 'qris' &&
                  controller.paymentSettings.value?.hasQrisUrl == true)
                const SizedBox(height: 16),

              // Price Summary
              CheckoutPriceSummaryWidget(
                subtotal: controller.subtotal,
                serviceFee: controller.serviceFee,
                tax: controller.taxAmount,
                discount: controller.discountAmount,
                total: controller.total,
                discountName:
                    controller.cartController.selectedDiscount.value?.name,
              ),
              const SizedBox(height: 80), // Space for bottom button
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cartController.cartItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => controller.cancelOrder(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.alertNormal,
                          side: BorderSide(color: AppColors.alertNormal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => controller.saveAsPending(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brownNormal,
                          side: BorderSide(color: AppColors.brownNormal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.hourglass_empty, size: 18),
                        label: const Text(
                          'Pending',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => controller.showCheckoutDoneConfirmation(
                                context,
                              ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[600],
                          side: BorderSide(color: Colors.green[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text(
                          'Done',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value
                        ? null
                        : () => controller.showCheckoutConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brownNormal,
                      disabledBackgroundColor: AppColors.greyNormal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isProcessing.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, color: AppColors.white),
                              const SizedBox(width: 12),
                              Text(
                                'Process Payment - ${_formatCurrency(controller.total)}',
                                style: AppTypography.buttonLarge.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.greyNormal,
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is Empty',
            style: AppTypography.h5.copyWith(color: AppColors.greyNormalActive),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some menu items to the cart first',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.greyNormal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelection() {
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
                  Icons.table_restaurant,
                  color: AppColors.brownNormal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Table (Optional)',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoadingTables.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return DropdownButtonFormField<int>(
                value: controller.selectedTable.value?.id,
                decoration: InputDecoration(
                  hintText: 'Select table...',
                  hintStyle: AppTypography.inputHint.copyWith(
                    color: AppColors.greyNormal,
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
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('No table', style: AppTypography.bodyMedium),
                  ),
                  ...controller.availableTables.map((table) {
                    return DropdownMenuItem<int>(
                      value: table.id,
                      child: Text(
                        '${table.tableName} (Capacity: ${table.capacity})',
                        style: AppTypography.bodyMedium,
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value == null) {
                    controller.setSelectedTable(null);
                  } else {
                    final table = controller.availableTables.firstWhere(
                      (t) => t.id == value,
                    );
                    controller.setSelectedTable(table);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerNameInput() {
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
                Icon(Icons.person, color: AppColors.brownNormal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Customer Name (Optional)',
                  style: AppTypography.h6.copyWith(color: AppColors.brownDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.customerNameController,
              style: AppTypography.input,
              decoration: InputDecoration(
                hintText: 'Enter customer name...',
                hintStyle: AppTypography.inputHint.copyWith(
                  color: AppColors.greyNormal,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.brownNormal,
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
              ),
              onChanged: controller.setCustomerName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountInfo() {
    final discount = controller.cartController.selectedDiscount.value;
    if (discount == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: AppColors.successLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.successNormal),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.discount, color: AppColors.successNormal, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discount Applied',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${discount.name} (${discount.displayText})',
                    style: AppTypography.bodyMediumBold.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '- ${_formatCurrency(controller.discountAmount)}',
              style: AppTypography.priceMedium.copyWith(
                color: AppColors.successNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
