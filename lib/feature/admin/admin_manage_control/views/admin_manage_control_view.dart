import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/views/admin_edit_category_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/views/admin_edit_menu_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/views/admin_edit_table_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/views/admin_edit_user_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/widgets/admin_manage_control_stats_card_widget.dart';
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
          Obx(
            () => AdminManageControlAppBar(
              currentTitle: controller.getCurrentTitle(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.manualRefresh,
              color: AppColors.brownDark,
              backgroundColor: AppColors.white,
              child: CustomScrollView(
                slivers: [
                  // Stats Section
                  SliverToBoxAdapter(child: _buildStatsSection()),

                  // Tab Bar
                  SliverToBoxAdapter(
                    child: AdminTabBar(controller: controller),
                  ),

                  // Tab Content
                  SliverFillRemaining(
                    child: Obx(
                      () => IndexedStack(
                        index: controller.currentTabIndex.value,
                        children: const [
                          AdminEditUserView(),
                          AdminEditMenuView(),
                          AdminEditCategoryView(),
                          AdminEditTableView(),
                        ],
                      ),
                    ),
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
    return Obx(() {
      final isLoading = controller.isLoadingStats.value;
      final isOffline = !controller.isOnline.value;
      final stats = controller.stats.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title with Offline Indicator
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.brownDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overview Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownDark,
                  ),
                ),

                if (!isLoading) ...[
                  // Hapus kondisi !isOffline
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOffline ? Icons.storage : Icons.sync,
                        size: 12,
                        color: AppColors.greyNormal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOffline
                            ? 'Using local data'
                            : 'Live data from server',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.greyNormal,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio:
                  1.1, // ✅ CHANGED: Slightly taller cards to prevent overflow
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                AdminStatsCard(
                  title: 'Users',
                  count: stats.totalUsers,
                  icon: Icons.people,
                  color: AppColors.blueNormal,
                  isLoading: isLoading,
                  isOffline: isOffline,
                ),
                AdminStatsCard(
                  title: 'Menus',
                  count: stats.totalMenus,
                  icon: Icons.restaurant_menu,
                  color: AppColors.orangeNormal,
                  isLoading: isLoading,
                  isOffline: isOffline,
                ),
                AdminStatsCard(
                  title: 'Categories',
                  count: stats.totalCategories,
                  icon: Icons.category,
                  color: AppColors.purpleNormal,
                  isLoading: isLoading,
                  isOffline: isOffline,
                ),
                AdminStatsCard(
                  title: 'Tables',
                  count: stats.totalTables,
                  icon: Icons.table_restaurant,
                  color: AppColors.tealNormal,
                  isLoading: isLoading,
                  isOffline: isOffline,
                ),
              ],
            ),

            // Last Updated Info (Only when online)
            if (!isOffline && !isLoading) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync, size: 12, color: AppColors.greyNormal),
                  const SizedBox(width: 4),
                  Text(
                    'Live data from server',
                    style: TextStyle(fontSize: 10, color: AppColors.greyNormal),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}
