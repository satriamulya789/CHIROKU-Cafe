import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:developer';

class AdminManageControlService {
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());

  /// Real-time stream of stats from local DB — works online and offline.
  /// Counts update instantly whenever any local table changes.
  Stream<AdminStatsModel> watchStats() {
    log('📊 Service: Starting real-time stats stream...');
    // Use Get.find to get the already-initialized DatabaseHelper singleton
    final db = Get.find<DatabaseHelper>().database;
    return db.watchAdminStats().map((raw) {
      return AdminStatsModel(
        totalUsers: raw['users'] ?? 0,
        totalMenus: raw['menus'] ?? 0,
        totalCategories: raw['categories'] ?? 0,
        totalTables: raw['tables'] ?? 0,
      );
    });
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
