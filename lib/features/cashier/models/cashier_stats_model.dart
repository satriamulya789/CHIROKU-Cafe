/// Model untuk statistik dashboard cashier
class CashierStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;
  final int tablesOccupied;
  final int tablesAvailable;

  CashierStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.tablesOccupied,
    required this.tablesAvailable,
  });

  factory CashierStats.fromMap(Map<String, dynamic> map) {
    return CashierStats(
      totalOrders: map['totalOrders'] ?? 0,
      pendingOrders: map['pendingOrders'] ?? 0,
      completedOrders: map['completedOrders'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      tablesOccupied: map['tablesOccupied'] ?? 0,
      tablesAvailable: map['tablesAvailable'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'totalRevenue': totalRevenue,
      'tablesOccupied': tablesOccupied,
      'tablesAvailable': tablesAvailable,
    };
  }

  CashierStats copyWith({
    int? totalOrders,
    int? pendingOrders,
    int? completedOrders,
    double? totalRevenue,
    int? tablesOccupied,
    int? tablesAvailable,
  }) {
    return CashierStats(
      totalOrders: totalOrders ?? this.totalOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      tablesOccupied: tablesOccupied ?? this.tablesOccupied,
      tablesAvailable: tablesAvailable ?? this.tablesAvailable,
    );
  }
}

/// Model untuk quick action di dashboard
class QuickAction {
  final String title;
  final String subtitle;
  final String icon;
  final String route;
  final int color;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}
