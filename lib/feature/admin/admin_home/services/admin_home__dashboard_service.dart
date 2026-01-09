import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_dashboard_stats_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_notification_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_stock_status_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/repositories/admin_home_repositories.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';

class DashboardService {
  final DashboardRepository _repository = DashboardRepository();
  final CustomSnackbar _snackbar = CustomSnackbar();

  Future<DashboardStatsModel?> getDashboardStats() async {
    try {
      return await _repository.getDashboardStats();
    } catch (e) {
      _snackbar.showErrorSnackbar('Failed to load dashboard statistics');
      return null;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _repository.getNotifications();
    } catch (e) {
      _snackbar.showErrorSnackbar('Failed to load notifications');
      return [];
    }
  }

  Future<List<StockStatusModel>> getStockStatus() async {
    try {
      return await _repository.getStockStatus();
    } catch (e) {
      _snackbar.showErrorSnackbar('Failed to load stock status');
      return [];
    }
  }

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  double calculatePercentageChange(int current, int previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }
}