import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailPage({super.key, required this.order});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = order['created_at']?.toString() ?? DateTime.now().toString();
    final orderItems = order['order_items'] as List? ?? [];
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0;
    final subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0;
    final serviceFee = (order['service_fee'] as num?)?.toDouble() ?? 0;
    final tax = (order['tax'] as num?)?.toDouble() ?? 0;
    final status = (order['order_status'] ?? order['status'] ?? 'pending').toString();
    final tableName = order['tables']?['table_name'] ?? order['tables']?['table_number'] ?? '-';
    final customerName = order['customer_name'] ?? '-';
    final userInfo = order['users'] as Map<String, dynamic>?;
    final cashierName = userInfo?['full_name'] ?? userInfo?['email'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Order #${order['id'] ?? '-'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order['id'] ?? '-'}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(createdAt),
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Info Rows
          _buildInfoRow(Icons.person, 'Kasir', cashierName),
          _buildInfoRow(Icons.table_restaurant, 'Meja', tableName.toString()),
          _buildInfoRow(Icons.person_outline, 'Pelanggan', customerName.toString()),

          const SizedBox(height: 12),

          // Items list
          Text(
            'Daftar Menu',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...orderItems.map<Widget>((item) {
            final menuData = item['menu'] as Map<String, dynamic>?;
            final menuName = menuData?['name'] ?? item['menu_name'] ?? '-';
            final qty = item['qty'] ?? item['quantity'] ?? 0;
            final price = (item['price'] as num?)?.toDouble() ?? 0;
            final subtotalItem = (item['subtotal'] as num?)?.toDouble() ?? (qty * price);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
                child: Text(qty.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ),
              title: Text(menuName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(_formatCurrency(price), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
              trailing: Text(_formatCurrency(subtotalItem), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            );
          }).toList(),

          const SizedBox(height: 12),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', subtotal),
                if (serviceFee > 0) _buildSummaryRow('Biaya Layanan', serviceFee),
                if (tax > 0) _buildSummaryRow('Pajak', tax),
                const Divider(),
                _buildSummaryRow('TOTAL', totalAmount, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle_outline),
              label: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          Text(
            _formatCurrency(value),
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
