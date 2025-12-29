import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminControlsPage extends StatelessWidget {
  const AdminControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Admin Controls',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Management Card
            AdminCard(
              icon: Icons.person,
              title: 'User Management',
              subtitle: 'Manage staff accounts & roles',
              primaryButtonLabel: 'Add User',
              primaryColor: Colors.green,
              primaryAction: () => Get.toNamed('/admin/controller?tab=0&action=add'),
              secondaryButtonLabel: 'View All',
              secondaryColor: Colors.blue,
              secondaryAction: () => Get.toNamed('/admin/controller?tab=0'),
              tertiaryButtonLabel: 'Roles',
              tertiaryColor: Colors.orange,
              tertiaryAction: () => Get.toNamed('/admin/controller?tab=0'),
              onCardTap: () => Get.toNamed('/admin/controller?tab=0'),
            ),
            const SizedBox(height: 16),
            
            // Table Management Card
            AdminCard(
              icon: Icons.table_restaurant,
              title: 'Table Management',
              subtitle: 'Configure tables & seating',
              primaryButtonLabel: 'Add Table',
              primaryColor: Colors.blue,
              primaryAction: () => Get.toNamed('/admin/controller?tab=1&action=add'),
              secondaryButtonLabel: 'View All',
              secondaryColor: Colors.green,
              secondaryAction: () => Get.toNamed('/admin/controller?tab=1'),
              onCardTap: () => Get.toNamed('/admin/controller?tab=1'),
            ),
            const SizedBox(height: 16),
            
            // Menu Management Card
            AdminCard(
              icon: Icons.restaurant_menu,
              title: 'Menu Management',
              subtitle: 'Food & drink items',
              primaryButtonLabel: 'Add Menu',
              primaryColor: Colors.orange,
              primaryAction: () => Get.toNamed('/admin/controller?tab=2&action=add'),
              secondaryButtonLabel: 'Foods',
              secondaryColor: Colors.blue,
              secondaryAction: () => Get.toNamed('/admin/controller?tab=2&category=food'),
              tertiaryButtonLabel: 'Beverages',
              tertiaryColor: Colors.green,
              tertiaryAction: () => Get.toNamed('/admin/controller?tab=2&category=beverage'),
              onCardTap: () => Get.toNamed('/admin/controller?tab=2'),
            ),
            const SizedBox(height: 16),
            
            // Reports & Analytics Card
            AdminCard(
              icon: Icons.analytics,
              title: 'Reports & Analytics',
              subtitle: 'Sales reports & statistics',
              primaryButtonLabel: 'Sales Report',
              primaryColor: Colors.purple,
              primaryAction: () => Get.snackbar('Info', 'Sales Report Coming Soon'),
              secondaryButtonLabel: 'Analytics',
              secondaryColor: Colors.indigo,
              secondaryAction: () => Get.snackbar('Info', 'Analytics Coming Soon'),
              onCardTap: () => Get.snackbar('Info', 'Reports Coming Soon'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final Color primaryColor;
  final VoidCallback primaryAction;
  final String? secondaryButtonLabel;
  final Color? secondaryColor;
  final VoidCallback? secondaryAction;
  final String? tertiaryButtonLabel;
  final Color? tertiaryColor;
  final VoidCallback? tertiaryAction;
  final VoidCallback? onCardTap;

  const AdminCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.primaryColor,
    required this.primaryAction,
    this.secondaryButtonLabel,
    this.secondaryColor,
    this.secondaryAction,
    this.tertiaryButtonLabel,
    this.tertiaryColor,
    this.tertiaryAction,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Icon(icon, color: primaryColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildButton(primaryButtonLabel, primaryColor, primaryAction),
                if (secondaryButtonLabel != null && secondaryAction != null)
                  _buildButton(secondaryButtonLabel!, secondaryColor!, secondaryAction!),
                if (tertiaryButtonLabel != null && tertiaryAction != null)
                  _buildButton(tertiaryButtonLabel!, tertiaryColor!, tertiaryAction!),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}