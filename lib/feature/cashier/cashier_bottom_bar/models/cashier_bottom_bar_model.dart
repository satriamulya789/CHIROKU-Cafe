import 'package:flutter/material.dart';

class CashierNavItemModel {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  CashierNavItemModel({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  static List<CashierNavItemModel> getItems() {
    return [
      CashierNavItemModel(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      CashierNavItemModel(
        icon: Icons.list_alt_outlined,
        activeIcon: Icons.list_alt,
        label: 'Orders',
      ),
      CashierNavItemModel(
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment,
        label: 'Report',
      ),
      CashierNavItemModel(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: 'Cart',
      ),
      CashierNavItemModel(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
      ),
    ];
  }
}