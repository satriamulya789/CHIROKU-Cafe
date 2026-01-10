import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManageControlRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AdminStatsModel> getStats() async {
    try {
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

      return AdminStatsModel(
        totalUsers: usersCount,
        totalMenus: menusCount,
        totalCategories: categoriesCount,
        totalTables: tablesCount,
      );
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }
}