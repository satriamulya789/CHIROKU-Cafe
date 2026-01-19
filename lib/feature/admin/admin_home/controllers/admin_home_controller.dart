import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/services/admin_home__dashboard_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/services/admin_home_user_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomeController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final UserService _userService = UserService();
  final CustomSnackbar _snackbar = CustomSnackbar();

  final isLoading = true.obs;
  final currentUser = Rxn<UserModel>();
  final dashboardStats = Rxn<DashboardStatsModel>();
  final notifications = <NotificationModel>[].obs;
  final stockStatus = <StockStatusModel>[].obs;
  final selectedChartType = 'bar'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadUserData(),
        loadDashboardStats(),
        loadNotifications(),
        loadStockStatus(),
      ]);
    } catch (e) {
      _snackbar.showErrorSnackbar('Failed to load dashboard data');
      print('Error in loadAllData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        print('User loaded: ${user.toJson()}');
      } else {
        print('No user found');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      // final stats = await _dashboardService.getDashboardStats();
      final stats = DashboardStatsModel(
        totalRevenue: 100000,
        totalOrders: 10,
        completedOrders: 8,
        pendingOrders: 1,
        cancelledOrders: 1,
        hourlySales: [
          HourlySalesData(hour: '08:00', sales: 10000, orderCount: 1),
          HourlySalesData(hour: '09:00', sales: 20000, orderCount: 2),
          HourlySalesData(hour: '10:00', sales: 15000, orderCount: 1),
          HourlySalesData(hour: '11:00', sales: 25000, orderCount: 2),
          HourlySalesData(hour: '12:00', sales: 30000, orderCount: 3),
          HourlySalesData(hour: '13:00', sales: 20000, orderCount: 2),
          HourlySalesData(hour: '14:00', sales: 35000, orderCount: 3),
          HourlySalesData(hour: '15:00', sales: 25000, orderCount: 2),
          HourlySalesData(hour: '16:00', sales: 40000, orderCount: 4),
          HourlySalesData(hour: '17:00', sales: 30000, orderCount: 3),
          HourlySalesData(hour: '18:00', sales: 45000, orderCount: 4),
          HourlySalesData(hour: '19:00', sales: 35000, orderCount: 3),
          HourlySalesData(hour: '20:00', sales: 50000, orderCount: 5),
          HourlySalesData(hour: '21:00', sales: 40000, orderCount: 4),
          HourlySalesData(hour: '22:00', sales: 55000, orderCount: 5),
        ], topProducts: [],
      );
      dashboardStats.value = stats;
      print('DUMMY Dashboard stats loaded:');
    } catch (e) {
      print('Error loading dashboard stats: $e');
    }
  }
  // Future<void> loadDashboardStats() async {
  //   try {
  //     final stats = await _dashboardService.getDashboardStats();
  //     if (stats != null) {
  //       dashboardStats.value = stats;
  //       print('Dashboard stats loaded}');
  //     } else {
  //       print('No dashboard stats found');
  //     }
  //   } catch (e) {
  //     print('Error loading dashboard stats: $e');
  //   }
  // }

  Future<void> loadNotifications() async {
    try {
      final notifs = await _dashboardService.getNotifications();
      notifications.value = notifs;
      print('Notifications loaded: ${notifs.length}');
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> loadStockStatus() async {
    try {
      final stocks = await _dashboardService.getStockStatus();
      stockStatus.value = stocks;
      print('Stock status loaded: ${stocks.length}');
    } catch (e) {
      print('Error loading stock status: $e');
    }
  }

  void toggleChartType() {
    selectedChartType.value =
        selectedChartType.value == 'bar' ? 'line' : 'bar';
  }

  Future<void> refreshData() async {
    await loadAllData();
    _snackbar.showSuccessSnackbar('Dashboard refreshed successfully');
  }

  String formatCurrency(int amount) {
    return _dashboardService.formatCurrency(amount);
  }

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;
}