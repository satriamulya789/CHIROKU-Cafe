import 'package:chiroku_cafe/feature/admin/admin_report/models/admin_report_transaction_summary_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReceiptPDF({
    required ReportTransaction transaction,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CHIROKU CAFE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Address Street No. 123, City',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.Text(
                'Order #${transaction.id}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Cashier: ${transaction.cashierName}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              if (transaction.customerName != null)
                pw.Text(
                  'Customer: ${transaction.customerName}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              if (transaction.tableName != null)
                pw.Text(
                  'Table: ${transaction.tableName}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              // Items header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Menu',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Text(
                    'Qty',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 0.5),
              // Items
              ...items.map((item) {
                final name = item['menu']?['name'] ?? 'Unknown';
                final qty = item['qty'] ?? 0;
                final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                final total = qty * price;
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              name,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                            pw.Text(
                              currencyFormat.format(price),
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        qty.toString(),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        currencyFormat.format(total),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    currencyFormat.format(transaction.total),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Payment Method: ${transaction.paymentMethod?.toUpperCase() ?? 'CASH'}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank You For Visiting!',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${transaction.id}.pdf',
    );
  }
}
