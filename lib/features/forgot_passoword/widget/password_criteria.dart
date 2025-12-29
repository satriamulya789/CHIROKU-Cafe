import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordCriteriaList extends StatelessWidget {
  final Map<String, bool> criteria;

  const PasswordCriteriaList({
    super.key,
    required this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password harus mengandung:',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildCriteriaItem(
              'Minimal 8 karakter', criteria['length'] ?? false),
          _buildCriteriaItem('Huruf kecil (a-z)', criteria['lowercase'] ?? false),
          _buildCriteriaItem('Huruf besar (A-Z)', criteria['uppercase'] ?? false),
          _buildCriteriaItem('Angka (0-9)', criteria['digit'] ?? false),
          _buildCriteriaItem('Simbol (!@#\$%^&*)', criteria['symbol'] ?? false),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}