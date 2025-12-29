import 'package:chiroku_cafe/features/cashier/pages/cart_page.dart';
import 'package:chiroku_cafe/features/cashier/pages/cashier_dashboard_page.dart';
import 'package:chiroku_cafe/features/cashier/pages/order_page.dart';
import 'package:chiroku_cafe/features/cashier/pages/report_page.dart';
import 'package:chiroku_cafe/configs/pages/settings_pages.dart';
import 'package:flutter/material.dart';

class BottomBarCashier extends StatefulWidget {
  const BottomBarCashier({super.key});

  @override
  State<BottomBarCashier> createState() => _BottomBarCashierState();
}

class _BottomBarCashierState extends State<BottomBarCashier> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const CashierDashboardPage(),
      const OrderPage(),
      const ReportPageS(),
      const CartPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
