class AdminTabModel {
  final int index;
  final String title;
  final String icon;
  final String route;

  AdminTabModel({
    required this.index,
    required this.title,
    required this.icon,
    required this.route,
  });
}

class AdminStatsModel {
  final int totalUsers;
  final int totalMenus;
  final int totalCategories;
  final int totalTables;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalMenus,
    required this.totalCategories,
    required this.totalTables,
  });

  factory AdminStatsModel.empty() {
    return AdminStatsModel(
      totalUsers: 0,
      totalMenus: 0,
      totalCategories: 0,
      totalTables: 0,
    );
  }
}