import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/controllers/admin_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/views/admin_home_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/views/admin_manage_control_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/views/admin_setting_view.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BottomBarController());
    final List<Widget> pages = const [
      AdminHomeView(),
      AdminManageControlView(),
      // MenuControlPage(),
      // ReportAdmin(),
      AdminSettingView(),
    ];

    return Obx(
      () => Scaffold(
        body: pages[c.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: c.selectedIndex.value,
          selectedItemColor: AppColors.brownDarker,
          unselectedItemColor: AppColors.brownNormal.withOpacity(0.5),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: c.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin Control',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'Report',
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
