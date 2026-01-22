import 'package:chiroku_cafe/shared/models/report/report_transaction_model.dart';
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
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'CHIROKU CAFE',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              pw.Center(child: pw.Text('Premium Coffee & Roastery')),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order ID: #${transaction.id}'),
                  pw.Text(
                    DateFormat('dd/MM/yy HH:mm').format(transaction.createdAt),
                  ),
                ],
              ),
              pw.Text('Cashier: ${transaction.cashierName}'),
              pw.Text('Customer: ${transaction.customerName ?? '-'}'),
              pw.Text('Table: ${transaction.tableName ?? '-'}'),
              pw.Divider(),
              ...items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${item['qty']}x ${item['menu']?['name'] ?? 'Unknown Item'}',
                        ),
                      ),
                      pw.Text(
                        currencyFormat.format(
                          item['total'] ??
                              ((item['qty'] as num? ?? 0) *
                                  (item['price'] as num? ?? 0)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(transaction.total),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Payment Method: ${transaction.paymentMethod?.toUpperCase() ?? 'CASH'}',
                ),
              ),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Thank You!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${transaction.id}',
    );
  }
}
