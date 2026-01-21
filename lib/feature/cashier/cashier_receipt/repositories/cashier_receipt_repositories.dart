import 'dart:developer';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_receipt/models/cashier_receipt_model.dart';

class ReceiptRepository {
  /// Generate PDF receipt
  Future<pw.Document> generateReceiptPDF(ReceiptModel receipt) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header
            pw.Text(
              'CHIROKU CAFE',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Jl. Contoh No. 123, Kota',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Telp: (021) 1234-5678',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Order Info
            _buildInfoRow('No. Order:', receipt.orderNumber),
            _buildInfoRow(
              'Tanggal:',
              DateFormat('dd/MM/yyyy HH:mm').format(receipt.createdAt),
            ),
            if (receipt.customerName != null &&
                receipt.customerName!.isNotEmpty)
              _buildInfoRow('Customer:', receipt.customerName!),
            if (receipt.tableName != null)
              _buildInfoRow('Meja:', receipt.tableName!),
            _buildInfoRow('Kasir:', receipt.cashierName),

            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Items Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'Item',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Qty',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Total',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),

            // Items
            ...receipt.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        item.menuName,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${item.quantity}x',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatCurrency(item.total),
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 4),

            // Totals
            _buildTotalRow('Subtotal:', receipt.subtotal),
            if (receipt.serviceFee > 0)
              _buildTotalRow('Service Fee:', receipt.serviceFee),
            if (receipt.tax > 0) _buildTotalRow('Tax:', receipt.tax),
            if (receipt.discount > 0)
              _buildTotalRow('Discount:', -receipt.discount),

            pw.SizedBox(height: 4),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 4),

            // Grand Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _formatCurrency(receipt.total),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Payment Info
            if (receipt.paymentMethod == 'cash' &&
                receipt.cashReceived != null) ...[
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 4),
              _buildTotalRow('Tunai:', receipt.cashReceived!),
              _buildTotalRow('Kembalian:', receipt.changeAmount ?? 0),
            ],

            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Footer
            pw.Text(
              'Terima kasih atas kunjungan Anda!',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Selamat menikmati',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 12),
          ],
        ),
      ),
    );

    return pdf;
  }

  /// Print receipt
  Future<void> printReceipt(ReceiptModel receipt) async {
    try {
      final pdf = await generateReceiptPDF(receipt);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Receipt_${receipt.orderNumber}.pdf',
      );
      log('✅ Receipt printed successfully');
    } catch (e) {
      log('❌ Error printing receipt: $e');
      rethrow;
    }
  }

  /// Save receipt as PDF
  Future<void> saveReceiptPDF(ReceiptModel receipt) async {
    try {
      final pdf = await generateReceiptPDF(receipt);
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Receipt_${receipt.orderNumber}.pdf',
      );
      log('✅ Receipt saved successfully');
    } catch (e) {
      log('❌ Error saving receipt: $e');
      rethrow;
    }
  }

  // Helper methods
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            _formatCurrency(amount.abs()),
            style: const pw.TextStyle(fontSize: 10),
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
}
