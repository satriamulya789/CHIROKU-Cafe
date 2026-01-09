import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_user_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/services/admin_home__dashboard_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/services/admin_home_user_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      final stats = await _dashboardService.getDashboardStats();
      if (stats != null) {
        dashboardStats.value = stats;
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      final notifs = await _dashboardService.getNotifications();
      notifications.value = notifs;
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> loadStockStatus() async {
    try {
      final stocks = await _dashboardService.getStockStatus();
      stockStatus.value = stocks;
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