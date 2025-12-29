import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final List<SummaryItem> items;
  final Color? headerColor;
  final IconData? headerIcon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.items,
    this.headerColor,
    this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (headerColor ?? Theme.of(context).primaryColor)
                  .withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (headerIcon != null) ...[
                  Icon(
                    headerIcon,
                    color: headerColor ?? Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) => _buildSummaryRow(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(SummaryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: item.isBold ? FontWeight.bold : FontWeight.normal,
              color: item.labelColor ?? Colors.grey[700],
            ),
          ),
          Text(
            item.isAmount
                ? _formatCurrency(item.value as double)
                : item.value.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: item.isBold ? FontWeight.bold : FontWeight.w600,
              color: item.valueColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
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

class SummaryItem {
  final String label;
  final dynamic value;
  final bool isAmount;
  final bool isBold;
  final Color? labelColor;
  final Color? valueColor;

  SummaryItem({
    required this.label,
    required this.value,
    this.isAmount = false,
    this.isBold = false,
    this.labelColor,
    this.valueColor,
  });
}
