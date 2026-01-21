import 'package:chiroku_cafe/feature/cashier/cashier_receipt/controllers/cashier_receipt_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReceiptView extends GetView<ReceiptController> {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'Payment Receipt',
          style: AppTypography.appBarTitle.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.brownDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final receipt = controller.receipt.value;

        if (receipt == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.greyNormal,
                ),
                const SizedBox(height: 16),
                Text(
                  'Receipt data not available',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.greyNormal,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Receipt Preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        Text(
                          'CHIROKU CAFE',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.brownDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Example St. No. 123, City',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.greyNormal,
                          ),
                        ),
                        Text(
                          'Phone: (021) 1234-5678',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.greyNormal,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppColors.greyNormal.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),

                        // Order Info
                        _buildInfoRow('Order No:', receipt.orderNumber),
                        _buildInfoRow(
                          'Date:',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(receipt.createdAt),
                        ),
                        if (receipt.customerName != null &&
                            receipt.customerName!.isNotEmpty)
                          _buildInfoRow('Customer:', receipt.customerName!),
                        if (receipt.tableName != null)
                          _buildInfoRow('Table:', receipt.tableName!),
                        _buildInfoRow('Cashier:', receipt.cashierName),

                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppColors.greyNormal.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),

                        // Items
                        ...receipt.items.map((item) => _buildItemRow(item)),

                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppColors.greyNormal.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),

                        // Totals
                        _buildTotalRow('Subtotal:', receipt.subtotal),
                        if (receipt.serviceFee > 0)
                          _buildTotalRow(
                            'Service Fee (5%):',
                            receipt.serviceFee,
                          ),
                        if (receipt.tax > 0)
                          _buildTotalRow('Tax (10%):', receipt.tax),
                        if (receipt.discount > 0)
                          _buildTotalRow(
                            'Discount:',
                            -receipt.discount,
                            isDiscount: true,
                          ),

                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 2,
                          color: AppColors.brownDark.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),

                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL:',
                              style: AppTypography.h4.copyWith(
                                color: AppColors.brownDark,
                              ),
                            ),
                            Text(
                              _formatCurrency(receipt.total),
                              style: AppTypography.h4.copyWith(
                                color: AppColors.brownDark,
                              ),
                            ),
                          ],
                        ),

                        // Payment Info
                        if (receipt.paymentMethod == 'cash' &&
                            receipt.cashReceived != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: AppColors.greyNormal.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          _buildTotalRow('Cash:', receipt.cashReceived!),
                          _buildTotalRow('Change:', receipt.changeAmount ?? 0),
                        ],

                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppColors.greyNormal.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),

                        // Footer
                        Text(
                          'Thank you for your visit!',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enjoy your meal',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.greyNormal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Print Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed:
                            controller.isPrinting.value ||
                                controller.isSaving.value
                            ? null
                            : () => _showPrintOptions(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownNormal,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon:
                            controller.isPrinting.value ||
                                controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.print),
                        label: Text(
                          controller.isPrinting.value
                              ? 'Printing...'
                              : controller.isSaving.value
                              ? 'Saving...'
                              : 'Print Receipt',
                          style: AppTypography.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : controller.completeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successNormal,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: controller.isProcessing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          controller.isProcessing.value
                              ? 'Processing...'
                              : 'Done',
                          style: AppTypography.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.greyNormal,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.menuName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatCurrency(item.total),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.quantity}x @ ${_formatCurrency(item.price)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.greyNormal,
            ),
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Note: ${item.note}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.greyNormal,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            _formatCurrency(amount.abs()),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: isDiscount ? AppColors.alertNormal : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _showPrintOptions(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.print, color: AppColors.brownDark),
            const SizedBox(width: 12),
            Text('Select Print Option', style: AppTypography.h5),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print, color: AppColors.brownNormal),
              title: Text('Print Receipt', style: AppTypography.bodyLarge),
              subtitle: Text(
                'Print to printer',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyNormal,
                ),
              ),
              onTap: () => Navigator.pop(context, 'print'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.brownNormal,
              ),
              title: Text('Save PDF', style: AppTypography.bodyLarge),
              subtitle: Text(
                'Save as PDF file',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyNormal,
                ),
              ),
              onTap: () => Navigator.pop(context, 'save'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.greyNormal),
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == 'print') {
      await controller.printReceipt();
    } else if (result == 'save') {
      await controller.saveReceiptPDF();
    }
  }
}
