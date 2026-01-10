import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/repositories/admin_manage_controll_repositories.dart';

class AdminManageControlService {
  final AdminManageControlRepositories _repository = AdminManageControlRepositories();

  Future<AdminStatsModel> fetchStats() async {
    return await _repository.getStats();
  }

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
}