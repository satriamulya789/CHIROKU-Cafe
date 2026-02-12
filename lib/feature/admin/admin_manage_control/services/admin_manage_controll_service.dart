import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/repositories/admin_manage_controll_repositories.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer';

class AdminManageControlService {
  final AdminManageControlRepositories _repository = AdminManageControlRepositories();
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());

  /// Fetch stats (returns empty if offline/error)
  Future<AdminStatsModel> fetchStats() async {
    try {
      final isOnline = await _networkInfo.isConnected;
      log('📊 Service: Fetching stats (${isOnline ? "Online" : "Offline"})...');
      
      final stats = await _repository.getStats();
      log('✅ Service: Stats loaded - $stats');
      
      return stats;
    } catch (e) {
      log('❌ Service: Error fetching stats: $e');
      return AdminStatsModel.empty();
    }
  }

  /// Get tab list for admin control
  List<AdminTabModel> getTabList() {
    return [
      AdminTabModel(
        index: 0,
        title: 'User',
        icon: 'people',
        route: '/admin-edit-user',
      ),
      AdminTabModel(
        index: 1,
        title: 'Menu',
        icon: 'restaurant_menu',
        route: '/admin-edit-menu',
      ),
      AdminTabModel(
        index: 2,
        title: 'Category',
        icon: 'category',
        route: '/admin-edit-category',
      ),
      AdminTabModel(
        index: 3,
        title: 'Table',
        icon: 'table_restaurant',
        route: '/admin-edit-table',
      ),
    ];
  }

  /// Check online status
  Future<bool> isOnline() async {
    return await _networkInfo.isConnected;
  }
}