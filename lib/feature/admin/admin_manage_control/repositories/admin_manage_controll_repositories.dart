import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class AdminManageControlRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());
  final _db = DatabaseHelper();

  Future<AdminStatsModel> getStats() async {
    try {
      final isOnline = await _networkInfo.isConnected;

      if (!isOnline) {
        log('📴 Offline: Fetching stats from local database...');
        final localStats = await _db.database.getAdminStats();

        return AdminStatsModel(
          totalUsers: localStats['users'] ?? 0,
          totalMenus: localStats['menus'] ?? 0,
          totalCategories: localStats['categories'] ?? 0,
          totalTables: localStats['tables'] ?? 0,
        );
      }

      log('🌐 Online: Fetching stats from Supabase...');

      // Get counts from each table
      final usersCount = await _supabase
          .from(ApiConstant.usersTable)
          .count(CountOption.exact);

      final menusCount = await _supabase
          .from(ApiConstant.menuTable)
          .count(CountOption.exact);

      final categoriesCount = await _supabase
          .from(ApiConstant.categoriesTable)
          .count(CountOption.exact);

      final tablesCount = await _supabase
          .from(ApiConstant.tablesTable)
          .count(CountOption.exact);

      log('✅ Stats fetched from Supabase');
      return AdminStatsModel(
        totalUsers: usersCount,
        totalMenus: menusCount,
        totalCategories: categoriesCount,
        totalTables: tablesCount,
      );
    } catch (e) {
      log('❌ Error fetching stats: $e');
      // Fallback to local database on error
      try {
        log('🔄 Attempting to fetch from local database as fallback...');
        final localStats = await _db.database.getAdminStats();

        return AdminStatsModel(
          totalUsers: localStats['users'] ?? 0,
          totalMenus: localStats['menus'] ?? 0,
          totalCategories: localStats['categories'] ?? 0,
          totalTables: localStats['tables'] ?? 0,
        );
      } catch (localError) {
        log('❌ Error fetching from local database: $localError');
        return AdminStatsModel.empty();
      }
    }
  }
}
