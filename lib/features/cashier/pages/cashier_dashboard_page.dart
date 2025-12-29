import 'package:chiroku_cafe/shared/models/table_models.dart';
import 'package:chiroku_cafe/shared/models/order_models.dart';
import 'package:chiroku_cafe/shared/repositories/table/table_service.dart';
import 'package:chiroku_cafe/shared/repositories/cart/cart_service.dart';
import 'package:chiroku_cafe/shared/repositories/order/order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chiroku_cafe/features/cashier/widgets/table_status_card.dart';

class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage>
    with WidgetsBindingObserver {
  final TableService _tableService = TableService();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final supabase = Supabase.instance.client;

  List<TableModel> tables = [];
  List<Map<String, dynamic>> tableOrders = [];
  int cartItemCount = 0;
  bool isLoading = true;
  
  // Statistics
  int availableCount = 0;
  int occupiedCount = 0;
  int reservedCount = 0;
  
  StreamSubscription? _tableSubscription;
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tableSubscription?.cancel();
    _orderSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _setupRealtimeSubscriptions() {
    // Subscribe to table changes
    _tableSubscription = supabase
        .from('tables')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadData();
          }
        });

    // Subscribe to order changes
    _orderSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadData();
          }
        });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final tablesData = await _tableService.getTables();
      final ordersData = await _orderService.getActiveOrders();
      final cartItems = await _cartService.getCartItems();
      final cartCount = cartItems.length;

      if (!mounted) return;

      setState(() {
        tables = tablesData;
        tableOrders = ordersData
            .map((order) => {
                  'id': order.id,
                  'table_id': order.tableId,
                  'customer_name': order.customerName,
                  'total': order.total,
                  'order_status': order.orderStatus,
                  'created_at': order.createdAt.toIso8601String(),
                })
            .toList();
        cartItemCount = cartCount;
        
        // Calculate statistics
        availableCount = tables.where((t) => t.isAvailable).length;
        occupiedCount = tables.where((t) => t.isOccupied).length;
        reservedCount = tables.where((t) => t.isReserved).length;
        
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Gagal memuat data: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  bool _hasNotifications() {
    return tableOrders.any((order) => order['order_status'] == 'ready');
  }

  String _getNotificationMessage() {
    final readyOrders = tableOrders.where((order) => order['order_status'] == 'ready').length;
    return '$readyOrders pesanan siap disajikan';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _formatDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Kasir',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartItemCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Get.toNamed('/cashier/cart'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Banner (if needed)
              if (_hasNotifications())
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber[300] ?? Colors.amber,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ada Pesanan Siap Saji!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                            Text(
                              _getNotificationMessage(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/cashier/orders'),
                        child: Text('Lihat'),
                      ),
                    ],
                  ),
                ),
              // Greeting Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Siap Melayani!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.coffee,
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              Text(
                'Status Meja',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Tersedia',
                      availableCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Terisi',
                      occupiedCount.toString(),
                      Colors.orange,
                      Icons.restaurant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Reserved',
                      reservedCount.toString(),
                      Colors.blue,
                      Icons.bookmark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  // Quick Cart Access
                  if (cartItemCount > 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton.icon(
                        onPressed: () => Get.toNamed('/cashier/cart'),
                        icon: Icon(
                          Icons.shopping_cart,
                          color: Colors.orange,
                          size: 16,
                        ),
                        label: Text(
                          'Keranjang ($cartItemCount)',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Enhanced Quick Actions dengan info real-time
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedActionCard(
                          'Order Baru',
                          Icons.add_shopping_cart,
                          Colors.blue,
                          'Buat pesanan baru',
                          () => Get.toNamed('/cashier/order'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedActionCard(
                          'Keranjang',
                          Icons.shopping_cart,
                          Colors.orange,
                          cartItemCount > 0 ? '$cartItemCount item' : 'Kosong',
                          () => Get.toNamed('/cashier/cart'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedActionCard(
                          'Kelola Order',
                          Icons.assignment,
                          Colors.teal,
                          'Lihat semua order',
                          () => Get.toNamed('/cashier/orders'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedActionCard(
                          'Laporan',
                          Icons.assessment,
                          Colors.purple,
                          'Lihat laporan',
                          () => Get.toNamed('/cashier/report'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders Section
              FutureBuilder<List<OrderModel>>(
                future: _loadRecentOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    final orders = snapshot.data ?? [];
                    if (orders.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pesanan Terbaru',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed('/cashier/orders'),
                              child: Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontStyle: GoogleFonts.montserrat().fontStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...orders
                            .take(3)
                            .map((order) => _buildRecentOrderCard(order)),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Tables Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua Meja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.toNamed('/cashier/tables'),
                    icon: const Icon(Icons.grid_view, size: 18),
                    label: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tables Grid
              isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : tables.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // responsive columns based on available width
                        final width = constraints.maxWidth;
                        int crossAxisCount = 2;
                        if (width > 1100) {
                          crossAxisCount = 4;
                        } else if (width > 800) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: tables.length > 6 ? 6 : tables.length,
                          itemBuilder: (context, index) {
                            final table = tables[index];
                            return _buildTableCard(table);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed('/cashier/order');
          _loadData();
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          'Order Baru',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionCard(
    String label,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: GoogleFonts.montserrat().fontStyle,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTableTap(TableModel table, Map<String, dynamic> activeOrder) {
    if (!mounted) return;

    if (table.isAvailable && activeOrder.isEmpty) {
      // Start new order for available table
      _startNewOrder(table);
    } else if (activeOrder.isNotEmpty) {
      // Show order details and actions for occupied table
      _showTableOrderOptions(table, activeOrder);
    } else {
      // Show table info for other statuses
      _showTableInfo(table);
    }
  }

  void _startNewOrder(TableModel table) async {
    if (!mounted) return;

    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Mulai Order Baru',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Mulai pesanan baru untuk ${table.tableName}?',
          style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Mulai Order',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Get.toNamed('/cashier/order', arguments: {'table': table});
      if (mounted) {
        _loadData(); // Refresh data after returning
      }
    }
  }

  void _showTableOrderOptions(
    TableModel table,
    Map<String, dynamic> orderData,
  ) {
    if (!mounted) return;

    final orderId = orderData['id'];
    final customerName = orderData['customer_name']?.toString() ?? 'Guest';
    final createdAt =
        orderData['created_at']?.toString() ?? DateTime.now().toIso8601String();
    final total = (orderData['total'] is num)
        ? (orderData['total'] as num).toDouble()
        : 0.0;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.table_restaurant,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.tableName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        'Order #$orderId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm, dd MMM').format(
                          DateTime.tryParse(createdAt) ?? DateTime.now(),
                        ),
                        style: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(total),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(
                        '/cashier/orders',
                        arguments: {'orderId': orderId},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.visibility, color: Colors.white),
                    label: Text(
                      'Lihat Detail Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Done button - untuk menyelesaikan order dan membebaskan meja
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.back();
                      await _completeTableOrder(table, orderData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      'Done - Selesaikan & Bebaskan Meja',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _loadData();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Refresh Status',
                      style: TextStyle(
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTableInfo(TableModel table) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.table_restaurant, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              table.tableName,
              style: TextStyle(
                fontStyle: GoogleFonts.montserrat().fontStyle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${table.status}',
              style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
            ),
            Text(
              'Kapasitas: ${table.capacity} orang',
              style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Tutup')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.table_restaurant_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada meja tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<OrderModel>> _loadRecentOrders() async {
    try {
      final orders = await _orderService.getOrders(limit: 5);
      return orders
          .where(
            (order) =>
                order.orderStatus == 'pending' ||
                order.orderStatus == 'paid' ||
                order.orderStatus == 'completed' ||
                order.orderStatus == 'cancelled' ||
                order.orderStatus == 'preparing',
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'color': Colors.orange, 'text': 'On Process'};
      case 'preparing':
        return {'color': Colors.blue, 'text': 'On Process'};
      case 'ready':
        return {'color': Colors.purple, 'text': 'On Process'};
      case 'paid':
        return {'color': Colors.green, 'text': 'Complete'};
      case 'completed':
        return {'color': Colors.green, 'text': 'Complete'};
      case 'cancelled':
        return {'color': Colors.red, 'text': 'Cancel'};
      case 'void':
        return {'color': Colors.grey, 'text': 'Cancel'};
      default:
        return {'color': Colors.grey, 'text': status};
    }
  }

  Widget _buildRecentOrderCard(OrderModel order) {
    final statusInfo = _getStatusInfo(order.orderStatus);
    final statusColor = statusInfo['color'];
    final statusText = statusInfo['text'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Order Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.receipt_long, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.total),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (order.tableId != null) ...[
                            Icon(
                              Icons.table_restaurant,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.tableName ?? 'Meja ${order.tableId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                          ] else
                            Text(
                              'Takeaway',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTableOrder(
    TableModel table,
    Map<String, dynamic> orderData,
  ) async {
    if (!mounted) return;

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 12),
            Text('Selesaikan Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer sudah selesai makan?'),
            const SizedBox(height: 8),
            Text(
              'Meja ${table.tableName} akan dibebaskan dan siap untuk customer berikutnya.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Ya, Selesaikan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Close the bottom sheet first
    Get.back();

    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final orderId = orderData['id'];
      final tableId = table.id;

      if (orderId == null) {
        throw Exception('Order ID tidak valid');
      }

      // 1. Update order status ke 'completed' (kitchen finished)
      await _orderService.updateOrderStatus(orderId, 'completed');

      // 2. Mark table as 'reserved' so cashier must finalize in Kelola Pesanan
      await _tableService.updateTableStatus(tableId, 'reserved');

      // Close loading
      if (mounted) {
        Get.back();
      }

      // Show success message
      if (mounted) {
        Get.snackbar(
          'Berhasil',
          'Order selesai! ${table.tableName} sudah dibebaskan.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }

      // Refresh data to update dashboard
      if (mounted) {
        await _loadData();
      }
    } catch (e) {
      // Close loading if error
      if (mounted) {
        Get.back();
      }

      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal menyelesaikan order: ${e.toString()}',
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Widget _buildTableCard(TableModel table) {
    // Find active order for this table
    final activeOrder = tableOrders.firstWhere(
      (order) => order['table_id'] == table.id,
      orElse: () => <String, dynamic>{},
    );

    final hasActiveOrder = activeOrder.isNotEmpty;

    // Determine status string for TableStatusCard
    String statusForWidget;
    if (table.isAvailable && !hasActiveOrder) {
      statusForWidget = 'available';
    } else if (table.isReserved) {
      statusForWidget = 'reserved';
    } else {
      statusForWidget = 'occupied';
    }

    final customerName = hasActiveOrder
        ? (activeOrder['customer_name']?.toString())
        : null;

    final orderNumber = hasActiveOrder
        ? (activeOrder['id'] != null ? activeOrder['id'].toString() : null)
        : null;

    return TableStatusCard(
      tableName: table.tableName,
      capacity: table.capacity,
      status: statusForWidget,
      customerName: customerName,
      orderNumber: orderNumber,
      onTap: () => _handleTableTap(table, activeOrder),
    );
  }
}
