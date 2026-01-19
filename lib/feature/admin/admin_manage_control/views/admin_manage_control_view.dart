import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/views/admin_edit_category_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/views/admin_edit_menu_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/views/admin_edit_table_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/views/admin_edit_user_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/widgets/admin_manage_control_tab_bar_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/widgets/admin_manage_controll_app_bar_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminManageControlView extends GetView<AdminManageControlController> {
  const AdminManageControlView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          // AppBar dengan tabTitle dinamis
          Obx(() => AdminManageControlAppBar(
                currentTitle: controller.getCurrentTitle(),
                onProfileTap: () => Get.toNamed('/admin/settings'),
              )),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.refreshCurrentTab();
              },
              color: AppColors.brownDark,
              backgroundColor: AppColors.white,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildStatsSection(),
                  ),
                  SliverToBoxAdapter(
                    child: AdminTabBar(controller: controller),
                  ),
                  SliverFillRemaining(
                    child: Obx(() => IndexedStack(
                          index: controller.currentTabIndex.value,
                          children: const [
                            AdminEditUserView(),
                            AdminEditMenuView(),
                            AdminEditCategoryView(),
                            AdminEditTableView(),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final controller = Get.find<AdminManageControlController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoadingStats.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                color: AppColors.brownNormal,
              ),
            ),
          );
        }

        // ...isi statistik sesuai kebutuhan...
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics Overview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.brownDark,
              ),
            ),
            const SizedBox(height: 16),
            // ...stat cards...
          ],
        );
      }),
    );
  }
}