import 'package:chiroku_cafe/feature/cashier/cashier_bottom_bar/controllers/cashier_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/views/cashier_cart_view.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/views/cashier_order_view.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_setting/views/cashier_setting_view.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashierBottomBarView extends StatelessWidget {
  const CashierBottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CashierBottomBarController());
    final List<Widget> pages = [
      const OrderPage(),
      CartPage(),
      CashierSettingView()
    ];

    return Obx(
      () => Scaffold(
        body: pages[c.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: c.selectedIndex.value,
          selectedItemColor: AppColors.brownDark,
          unselectedItemColor: AppColors.greyNormal,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: c.changeIndex,
          items: const [
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
      ),
    );
  }
}