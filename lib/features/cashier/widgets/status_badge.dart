import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({super.key, required this.status, this.customLabel});

  Map<String, dynamic> _getStatusInfo() {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'color': Colors.orange,
          'label': 'Menunggu',
          'icon': Icons.schedule,
        };
      case 'preparing':
        return {
          'color': Colors.blue,
          'label': 'Diproses',
          'icon': Icons.restaurant,
        };
      case 'ready':
        return {
          'color': Colors.purple,
          'label': 'Siap',
          'icon': Icons.done_all,
        };
      case 'paid':
        return {
          'color': Colors.green,
          'label': 'Dibayar',
          'icon': Icons.check_circle,
        };
      case 'completed':
        return {
          'color': Colors.teal,
          'label': 'Selesai',
          'icon': Icons.check_circle_outline,
        };
      case 'cancelled':
      case 'void':
        return {
          'color': Colors.red,
          'label': 'Dibatalkan',
          'icon': Icons.cancel,
        };
      case 'available':
        return {
          'color': Colors.green,
          'label': 'Tersedia',
          'icon': Icons.check_circle,
        };
      case 'occupied':
        return {
          'color': Colors.orange,
          'label': 'Terisi',
          'icon': Icons.restaurant,
        };
      case 'reserved':
        return {
          'color': Colors.blue,
          'label': 'Direservasi',
          'icon': Icons.bookmark,
        };
      default:
        return {
          'color': Colors.grey,
          'label': status,
          'icon': Icons.help_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getStatusInfo();
    final color = info['color'] as Color;
    final label = customLabel ?? info['label'] as String;
    final icon = info['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
