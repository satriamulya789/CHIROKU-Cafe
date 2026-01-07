import 'package:chiroku_cafe/env/env.dart';

class ApiConstant {
  // Gunakan Env dari envied, bukan dotenv
  static String get supabaseUrl => Env.supabaseUrl;
  static String get supabaseAnonKey => Env.supabaseAnonKey;
  
  static const String usersTable = 'users';
  static const String avatarsUrl = 'avatars';
  static const String menuTable = 'menu';
  static const String tablesTable = 'tables';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String discountsTable = 'discounts';
  static const String paymentsTable = 'payments';
}