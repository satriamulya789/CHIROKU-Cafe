import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableStatusCard extends StatelessWidget {
  final String tableName;
  final int capacity;
  final String status;
  final String? customerName;
  final String? orderNumber;
  final VoidCallback? onTap;

  const TableStatusCard({
    super.key,
    required this.tableName,
    required this.capacity,
    required this.status,
    this.customerName,
    this.orderNumber,
    this.onTap,
  });

  Map<String, dynamic> _getStatusInfo() {
    switch (status.toLowerCase()) {
      case 'available':
        return {
          'color': Colors.green,
          'label': 'Tersedia',
          'icon': Icons.check_circle,
          'bgColor': Colors.green.shade50,
        };
      case 'occupied':
        return {
          'color': Colors.orange,
          'label': 'Terisi',
          'icon': Icons.restaurant,
          'bgColor': Colors.orange.shade50,
        };
      case 'reserved':
        return {
          'color': Colors.blue,
          'label': 'Direservasi',
          'icon': Icons.bookmark,
          'bgColor': Colors.blue.shade50,
        };
      default:
        return {
          'color': Colors.grey,
          'label': status,
          'icon': Icons.table_restaurant,
          'bgColor': Colors.grey.shade50,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    final statusColor = statusInfo['color'] as Color;
    final statusLabel = statusInfo['label'] as String;
    final statusIcon = statusInfo['icon'] as IconData;
    final bgColor = statusInfo['bgColor'] as Color;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgColor, Colors.white],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Table Name & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.table_restaurant,
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              tableName,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 3),
                          Text(
                            statusLabel,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Capacity Info
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      'Kapasitas: $capacity orang',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Customer & Order Info (if occupied/reserved)
                if (customerName != null || orderNumber != null) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  if (customerName != null)
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            customerName!,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (orderNumber != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.receipt, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Order #$orderNumber',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
