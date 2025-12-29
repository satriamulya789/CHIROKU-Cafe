import 'package:chiroku_cafe/shared/models/order_models.dart';
import 'package:chiroku_cafe/shared/repositories/receipt/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReceiptViewPage extends StatelessWidget {
  final OrderModel order;

  const ReceiptViewPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final receiptService = ReceiptService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Struk Pesanan #${order.id}',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(receiptService),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReceipt(receiptService),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(receiptService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Receipt Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    'CHIROKU CAFE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jl. Cafe No.123, Jakarta',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  Text(
                    'Telp: (021) 123-4567',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Order Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No. Pesanan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        '#${order.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal:',
                        style: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                          'id_ID',
                        ).format(order.createdAt),
                        style: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                  if (order.tableId != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meja:',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                        Text(
                          order.tableName ?? 'Meja ${order.tableId}',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.cashierName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kasir:',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                        Text(
                          order.cashierName!,
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.customerName != null &&
                      order.customerName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pelanggan:',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                        Text(
                          order.customerName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Items
                  ...order.items
                          ?.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.menuName ?? 'Unknown Item',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: GoogleFonts.montserrat()
                                                .fontStyle,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(item.price),
                                        style: TextStyle(
                                          fontStyle: GoogleFonts.montserrat()
                                              .fontStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.qty} x ${_formatCurrency(item.price)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontStyle: GoogleFonts.montserrat()
                                              .fontStyle,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(item.subtotal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: GoogleFonts.montserrat()
                                              .fontStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList() ??
                      [],

                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Totals
                  _buildTotalRow('Subtotal:', order.subtotal),
                  if (order.serviceFee > 0)
                    _buildTotalRow('Biaya Layanan (5%):', order.serviceFee),
                  if (order.tax > 0) _buildTotalRow('Pajak (10%):', order.tax),
                  if (order.discount > 0)
                    _buildTotalRow(
                      'Diskon:',
                      -order.discount,
                      color: Colors.red,
                    ),
                  const SizedBox(height: 8),
                  Container(height: 2, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.total),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    'Terima kasih atas kunjungan Anda!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan datang kembali',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReceipt(receiptService),
                    icon: const Icon(Icons.share),
                    label: Text(
                      'Bagikan',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReceipt(receiptService),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: Text(
                      'Unduh',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _shareReceipt(ReceiptService receiptService) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await receiptService.shareReceipt(order);

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        'Struk berhasil dibagikan',
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal membagikan struk: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    }
  }

  void _downloadReceipt(ReceiptService receiptService) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await receiptService.saveReceiptPDF(order);

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        'Struk berhasil disimpan ke Downloads',
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal menyimpan struk: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    }
  }

  void _printReceipt(ReceiptService receiptService) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await receiptService.printReceipt(order);

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        'Struk berhasil dicetak',
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    }
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
