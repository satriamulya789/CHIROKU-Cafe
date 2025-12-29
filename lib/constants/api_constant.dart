/// API Constants
class ApiConstants {
  // Supabase Configuration
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL');
  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // API Endpoints (if needed for custom endpoints)
  static const String baseUrl = '';
  
  // Table Names
  static const String usersTable = 'users';
  static const String menusTable = 'menus';
  static const String ordersTable = 'orders';
  static const String tablesTable = 'tables';
  static const String categoriesTable = 'categories';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
