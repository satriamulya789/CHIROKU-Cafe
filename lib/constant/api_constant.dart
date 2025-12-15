class ApiConstant {
    static  String get supabaseUrl => String.fromEnvironment('SUPABASE_URL');
    static  String get supabaseAnonKey => String.fromEnvironment('SUPABASE_ANON_KEY');

    static const String usersTable = 'users';          // data user/kasir/admin
    static const String menusTable = 'menu';           // daftar menu
    static const String tablesTable = 'tables';        // meja pelanggan
    static const String ordersTable = 'orders';        // order utama
    static const String orderItemsTable = 'order_items'; // item dalam order
    static const String discountsTable = 'discounts';  // kode diskon
    static const String paymentsTable = 'payments';

    

}
