import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_notification_card_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_app_bar.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_notification_bottom_sheet.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_quick_action.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_sales_chart.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_stats_section.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_stock_section.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/widgets/admin_home_view_widget/admin_home_view_welcome_user.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AdminHomeViewAppBar(
        user: controller.currentUser.value,
        unreadCount: controller.unreadNotificationsCount,
        onNotificationTap: _showNotificationsBottomSheet,
        controller: controller,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brownDark),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.brownDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () =>
                      WelcomeSectionWidget(user: controller.currentUser.value),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => StatsSectionWidget(
                    stats: controller.dashboardStats.value,
                    formatCurrency: controller.formatCurrency,
                  ),
                ),
                const SizedBox(height: 24),
                const QuickActionsWidget(),
                const SizedBox(height: 24),
                Obx(
                  () => SalesChartSectionWidget(
                    stats: controller.dashboardStats.value,
                    selectedChartType: controller.selectedChartType,
                    formatCurrency: controller.formatCurrency,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => StockSectionWidget(
                    stocks: controller.stockStatus.take(5).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showNotificationsBottomSheet() {
    NotificationsBottomSheet.show(
      notifications: controller.notifications,
      onNotificationTap: _handleNotificationTap,
      notificationCardBuilder: (notif, onTap) =>
          NotificationCardWidget(notification: notif, onTap: onTap),
    );
  }

  void _handleNotificationTap(notification) {
    Get.back();
    switch (notification.type) {
      case 'order':
        Get.toNamed('/orders');
        break;
      case 'stock':
      case 'alert':
        Get.toNamed('/admin/controller?tab=2');
        break;
      default:
        break;
    }
  }
}
