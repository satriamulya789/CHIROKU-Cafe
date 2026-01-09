import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_hourly_sales.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/models/admin_home_top_product_model.dart';

class DashboardStatsModel {
  final int totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final List<HourlySalesData> hourlySales;
  final List<TopProductData> topProducts;

  DashboardStatsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.hourlySales,
    required this.topProducts,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalRevenue: json['total_revenue'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? 0,
      hourlySales: (json['hourly_sales'] as List?)
          ?.map((e) => HourlySalesData.fromJson(e))
          .toList() ?? [],
      topProducts: (json['top_products'] as List?)
          ?.map((e) => TopProductData.fromJson(e))
          .toList() ?? [],
    );
  }
}