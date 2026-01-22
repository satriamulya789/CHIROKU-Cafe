class ReportStat {
  final int totalOrders;
  final double totalRevenue;
  final double avgRevenue;
  final int itemsSold;

  ReportStat({
    required this.totalOrders,
    required this.totalRevenue,
    required this.avgRevenue,
    required this.itemsSold,
  });
}

class ReportProductStat {
  final int menuId;
  final String name;
  final double price;
  final int totalQty;
  final double totalRevenue;

  ReportProductStat({
    required this.menuId,
    required this.name,
    required this.price,
    required this.totalQty,
    required this.totalRevenue,
  });
}

class ReportCashierStat {
  final String cashierId;
  final String cashierName;
  final int totalOrders;
  final double totalRevenue;
  final int itemsSold;

  ReportCashierStat({
    required this.cashierId,
    required this.cashierName,
    required this.totalOrders,
    required this.totalRevenue,
    required this.itemsSold,
  });
}
