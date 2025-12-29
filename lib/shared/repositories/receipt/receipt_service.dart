import 'dart:io';
import 'package:chiroku_cafe/shared/models/order_models.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class ReceiptService {
  /// Generate PDF receipt for an order
  Future<pw.Document> generateReceiptPDF(OrderModel order) async {
    final pdf = pw.Document();
    
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CHIROKU CAFE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Kopi & Makanan Enak',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Jl. Contoh No. 123, Kota',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Telp: (021) 1234-5678',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Order Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No. Order:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('#${order.id}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tanggal:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(dateFormat.format(order.createdAt), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (order.tableName != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Meja:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(order.tableName!, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kasir:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(order.cashierName ?? 'System', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (order.customerName != null && order.customerName!.isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(order.customerName!, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Items
              pw.Text('PESANAN', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              
              ...?order.items?.map((item) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              item.menuName ?? 'Menu #${item.menuId}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            currencyFormat.format(item.subtotal),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text(
                            '  ${item.qty} x ${currencyFormat.format(item.price)}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 4),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(currencyFormat.format(order.subtotal), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              
              if (order.serviceFee > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Service:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(currencyFormat.format(order.serviceFee), style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              
              if (order.tax > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Pajak:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(currencyFormat.format(order.tax), style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              
              if (order.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('-${currencyFormat.format(order.discount)}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(order.total),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(),
              
              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Terima Kasih Atas Kunjungan Anda',
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Selamat Menikmati!',
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      order.isPaid ? 'LUNAS' : 'BELUM DIBAYAR',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Print receipt
  Future<void> printReceipt(OrderModel order) async {
    try {
      final pdf = await generateReceiptPDF(order);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'receipt_order_${order.id}.pdf',
      );
    } catch (e) {
      throw Exception('Failed to print receipt: $e');
    }
  }

  /// Share receipt as PDF
  Future<void> shareReceipt(OrderModel order) async {
    try {
      final pdf = await generateReceiptPDF(order);
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'receipt_order_${order.id}.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  /// Save receipt as PDF to downloads
  Future<String> saveReceiptPDF(OrderModel order) async {
    try {
      final pdf = await generateReceiptPDF(order);
      final bytes = await pdf.save();
      
      // Get downloads directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/receipt_order_${order.id}.pdf');
      
      // Write file
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to save receipt: $e');
    }
  }

  /// Generate simple text receipt (for thermal printer)
  String generateTextReceipt(OrderModel order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('================================');
    buffer.writeln('        CHIROKU CAFE');
    buffer.writeln('   Kopi & Makanan Enak');
    buffer.writeln('  Jl. Contoh No. 123, Kota');
    buffer.writeln('   Telp: (021) 1234-5678');
    buffer.writeln('================================');
    buffer.writeln();
    
    // Order info
    buffer.writeln('No. Order : #${order.id}');
    buffer.writeln('Tanggal   : ${dateFormat.format(order.createdAt)}');
    if (order.tableName != null) {
      buffer.writeln('Meja      : ${order.tableName}');
    }
    buffer.writeln('Kasir     : ${order.userId ?? "System"}');
    buffer.writeln('================================');
    buffer.writeln();
    
    // Items
    buffer.writeln('PESANAN:');
    buffer.writeln('--------------------------------');
    for (var item in order.items ?? []) {
      buffer.writeln(item.menuName ?? 'Menu #${item.menuId}');
      buffer.writeln('  ${item.qty} x ${currencyFormat.format(item.price)} = ${currencyFormat.format(item.subtotal)}');
    }
    buffer.writeln('================================');
    buffer.writeln();
    
    // Totals
    buffer.writeln('Subtotal  : ${currencyFormat.format(order.subtotal)}');
    if (order.serviceFee > 0) {
      buffer.writeln('Service   : ${currencyFormat.format(order.serviceFee)}');
    }
    if (order.tax > 0) {
      buffer.writeln('Pajak     : ${currencyFormat.format(order.tax)}');
    }
    if (order.discount > 0) {
      buffer.writeln('Diskon    : -${currencyFormat.format(order.discount)}');
    }
    buffer.writeln('================================');
    buffer.writeln('TOTAL     : ${currencyFormat.format(order.total)}');
    buffer.writeln('================================');
    buffer.writeln();
    
    // Footer
    buffer.writeln('  Terima Kasih Atas Kunjungan');
    buffer.writeln('      Selamat Menikmati!');
    buffer.writeln();
    buffer.writeln('    ${order.isPaid ? "LUNAS" : "BELUM DIBAYAR"}');
    buffer.writeln('================================');
    
    return buffer.toString();
  }
}
