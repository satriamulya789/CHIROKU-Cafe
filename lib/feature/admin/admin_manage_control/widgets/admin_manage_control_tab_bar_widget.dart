import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/widgets/admin_manage_control_tab_bar_item_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTabBar extends StatelessWidget {
  final AdminManageControlController controller;

  const AdminTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Obx(() => Row(
        children: [
          AdminTabItem(
            title: 'User',
            icon: Icons.people,
            isSelected: controller.currentTabIndex.value == 0,
            onTap: () => controller.changeTab(0),
          ),
          AdminTabItem(
            title: 'Menu',
            icon: Icons.restaurant_menu,
            isSelected: controller.currentTabIndex.value == 1,
            onTap: () => controller.changeTab(1),
          ),
          AdminTabItem(
            title: 'Category',
            icon: Icons.category,
            isSelected: controller.currentTabIndex.value == 2,
            onTap: () => controller.changeTab(2),
          ),
          AdminTabItem(
            title: 'Table',
            icon: Icons.table_restaurant,
            isSelected: controller.currentTabIndex.value == 3,
            onTap: () => controller.changeTab(3),
          ),
        ],
      )),
    );
  }
}