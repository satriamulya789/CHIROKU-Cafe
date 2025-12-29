import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
// Services not required here because receipt 'Done' no longer finalizes order

class ReceiptPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const ReceiptPage({super.key, required this.orderData});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final orderItems = widget.orderData['order_items'] as List? ?? [];
    final total = widget.orderData['total']?.toDouble() ?? 0.0;
    final subtotal = widget.orderData['subtotal']?.toDouble() ?? 0.0;
    final serviceFee = widget.orderData['service_fee']?.toDouble() ?? 0.0;
    final tax = widget.orderData['tax']?.toDouble() ?? 0.0;
    final discount = widget.orderData['discount']?.toDouble() ?? 0.0;
    final customerName =
        (widget.orderData['customer_name'] != null &&
            widget.orderData['customer_name'].toString().trim().isNotEmpty)
        ? widget.orderData['customer_name']
        : 'Walk-in Customer';
    final orderNumber = widget.orderData['order_number'] ?? '';
    final createdAt =
        DateTime.tryParse(widget.orderData['created_at'] ?? '') ??
        DateTime.now();
    final tableInfo = widget.orderData['tables'];
    final tableName = tableInfo != null ? tableInfo['table_name'] : 'No Table';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Struk Pembayaran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Cafe
                      Text(
                        'CHIROKU CAFE',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jl. Contoh No. 123, Kota',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Telp: (021) 1234-5678',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),

                      // Order Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No. Order:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            orderNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tanggal:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            customerName,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Table:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            tableName,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),

                      // Items List
                      ...orderItems.map<Widget>((item) {
                        final menu = item['menu'];
                        final menuName = menu != null
                            ? menu['name']
                            : 'Unknown Item';
                        final qty = item['qty']?.toString() ?? '0';
                        final price = item['price']?.toDouble() ?? 0.0;
                        final itemTotal = price * int.parse(qty);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  menuName,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  qty,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(price),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(itemTotal),
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),

                      // Totals
                      _buildTotalRow('Subtotal:', subtotal),
                      if (serviceFee > 0)
                        _buildTotalRow('Service Fee:', serviceFee),
                      if (tax > 0) _buildTotalRow('Tax:', tax),
                      if (discount > 0)
                        _buildTotalRow(
                          'Discount:',
                          -discount,
                          isDiscount: true,
                        ),

                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(total),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Terima kasih atas kunjungan Anda!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Selamat menikmati',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _printReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.print),
                    label: Text(
                      'Cetak Struk',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _completeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isProcessing
                          ? 'Processing...'
                          : 'Done - Selesaikan Order',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount.abs()),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDiscount ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt() async {
    // Show dialog untuk pilih jenis printer
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.print, color: Color(0xFF8B4513)),
            const SizedBox(width: 12),
            Text(
              'Pilih Jenis Printer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih metode pencetakan struk',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Thermal Printer Option
            InkWell(
              onTap: () => Navigator.pop(context, 'thermal'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF8B4513), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF8B4513).withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.print,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thermal Printer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Cetak ke printer bluetooth',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // PDF Printer Option
            InkWell(
              onTap: () => Navigator.pop(context, 'pdf'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.grey[700],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Printer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Cetak ke printer biasa',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == 'thermal') {
      // Navigasi ke halaman thermal printer dengan data struk
      _navigateToThermalPrinter();
    } else if (result == 'pdf') {
      // Cetak PDF seperti biasa
      try {
        final pdf = await _generatePDF();
        await Printing.layoutPdf(
          onLayout: (format) async => pdf,
          name: 'Receipt_${widget.orderData['order_number']}.pdf',
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mencetak struk: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _navigateToThermalPrinter() {
    // Prepare receipt data
    final orderItems = widget.orderData['order_items'] as List? ?? [];
    final receiptItems = orderItems.map((item) {
      final menuData = item['menu'];
      return {
        'name': menuData?['name'] ?? 'Unknown Item',
        'quantity': item['quantity'] ?? 0,
        'price': (item['price'] as num?)?.toDouble() ?? 0.0,
        'subtotal':
            ((item['quantity'] ?? 0) *
            ((item['price'] as num?)?.toDouble() ?? 0.0)),
      };
    }).toList();

    final subtotal = widget.orderData['subtotal']?.toDouble() ?? 0.0;
    final tax = widget.orderData['tax']?.toDouble() ?? 0.0;
    final discount = widget.orderData['discount']?.toDouble() ?? 0.0;
    final total = widget.orderData['total']?.toDouble() ?? 0.0;

    // Navigate to thermal printer page dengan data
    Get.toNamed(
      '/printer-settings',
      arguments: {
        'autoConnect': true,
        'printData': {
          'receiptNumber': widget.orderData['order_number'] ?? '',
          'cashierName': 'Kasir', // TODO: Get from session
          'items': receiptItems,
          'subtotal': subtotal,
          'tax': tax,
          'discount': discount,
          'total': total,
          'cash': 0.0, // TODO: Implement if needed
          'change': 0.0,
          'notes': 'Terima kasih telah berkunjung!',
        },
      },
    );
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();
    final orderItems = widget.orderData['order_items'] as List? ?? [];

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header
            pw.Text(
              'CHIROKU CAFE',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Jl. Contoh No. 123, Kota'),
            pw.Text('Telp: (021) 1234-5678'),
            pw.SizedBox(height: 16),

            // Order Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('No. Order: ${widget.orderData['order_number']}'),
                pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
              ],
            ),
            pw.SizedBox(height: 8),

            // Items
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Item',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Qty',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                ...orderItems.map<pw.TableRow>((item) {
                  final menu = item['menu'];
                  final menuName = menu != null ? menu['name'] : 'Unknown Item';
                  final qty = item['qty'] ?? 0;
                  final price = item['price']?.toDouble() ?? 0.0;
                  final total = price * qty;

                  return pw.TableRow(
                    children: [
                      pw.Text(menuName),
                      pw.Text(qty.toString()),
                      pw.Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(price),
                      ),
                      pw.Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(total),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 16),

            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(widget.orderData['total']?.toDouble() ?? 0.0),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Text('Terima kasih atas kunjungan Anda!'),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _completeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show success message
      Get.snackbar(
        'Berhasil',
        'Transaksi selesai. Kembali ke dashboard.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate back to home/dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/cashier-dashboard');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
