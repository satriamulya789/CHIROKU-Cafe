import 'package:chiroku_cafe/features/cashier/pages/sales_report_page.dart';
import 'package:chiroku_cafe/shared/repositories/order/order_service.dart';
import 'package:chiroku_cafe/shared/repositories/receipt/receipt_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/features/cashier/pages/order_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ReportPageS extends StatefulWidget {
  const ReportPageS({super.key});

  @override
  State<ReportPageS> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPageS>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;
  final OrderService _orderService = OrderService();
  final ReceiptService _receiptService = ReceiptService();

  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  Map<String, dynamic> todayStats = {};
  Map<String, dynamic> weekStats = {};
  Map<String, dynamic> monthStats = {};
  DateTime selectedDate = DateTime.now();
  StreamSubscription? _ordersSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupRealtimeUpdates();
  }

  void _navigateToSalesReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SalesReportPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    // Realtime subscription untuk orders
    _ordersSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((data) {
          if (mounted) {
            // Reload semua data ketika ada perubahan
            _loadData();
          }
        });

    // Periodic refresh setiap 30 detik sebagai backup
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      print('=== Loading Report Data ===');
      await Future.wait([
        _loadOrders(),
        _loadTodayStats(),
        _loadWeekStats(),
        _loadMonthStats(),
      ]);
      print('=== Report Data Loaded Successfully ===');

      // Show success message
      if (mounted) {
        Get.snackbar(
          'Berhasil',
          'Data laporan berhasil dimuat',
          backgroundColor: Colors.green[700],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('=== Error Loading Report Data: $e ===');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memuat data laporan: $e',
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select('''
            *, 
            order_items(*, menu(name, price)), 
            payments(*),
            users!orders_user_id_fkey(full_name, email),
            tables(table_name)
          ''')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      // If relation fails, try simpler query
      try {
        final response = await supabase
            .from('orders')
            .select('*, order_items(*, menu(name, price)), payments(*)')
            .order('created_at', ascending: false)
            .limit(50);

        setState(() {
          orders = List<Map<String, dynamic>>.from(response);
        });
      } catch (e2) {
        print('Error loading orders: $e2');
        setState(() {
          orders = [];
        });
      }
    }
  }

  Future<void> _loadTodayStats() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      print(
        'Loading today stats from ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}',
      );

      // Get paid or completed orders for today (count as revenue)
      final paidOrdersResponse = await supabase
          .from('orders')
          .select('total, id, order_status')
          .or('order_status.eq.paid,order_status.eq.completed')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      // Get all orders for today (including pending, preparing, etc.)
      final allOrdersResponse = await supabase
          .from('orders')
          .select('id, order_status')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      double totalRevenue = 0;
      for (var order in paidOrdersResponse) {
        double orderTotal = (order['total'] as num?)?.toDouble() ?? 0;
        totalRevenue += orderTotal;
      }

      print(
        'Today Stats - Total Orders: ${allOrdersResponse.length}, Paid Orders: ${paidOrdersResponse.length}, Revenue: $totalRevenue',
      );

      setState(() {
        todayStats = {
          'orders': allOrdersResponse.length, // Total orders today
          'paid_orders': paidOrdersResponse.length, // Paid orders today
          'revenue': totalRevenue, // Revenue from paid orders
        };
      });
    } catch (e) {
      print('Error loading today stats: $e');
      setState(() {
        todayStats = {'orders': 0, 'paid_orders': 0, 'revenue': 0.0};
      });
    }
  }

  Future<void> _loadWeekStats() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      print(
        'Loading week stats from ${startOfWeek.toIso8601String()} to ${endOfWeek.toIso8601String()}',
      );

      // Get paid or completed orders for this week (count as revenue)
      final paidOrdersResponse = await supabase
          .from('orders')
          .select('total, id, order_status')
          .or('order_status.eq.paid,order_status.eq.completed')
          .gte('created_at', startOfWeek.toIso8601String())
          .lt('created_at', endOfWeek.toIso8601String());

      // Get all orders for this week
      final allOrdersResponse = await supabase
          .from('orders')
          .select('id, order_status')
          .gte('created_at', startOfWeek.toIso8601String())
          .lt('created_at', endOfWeek.toIso8601String());

      double totalRevenue = 0;
      for (var order in paidOrdersResponse) {
        double orderTotal = (order['total'] as num?)?.toDouble() ?? 0;
        totalRevenue += orderTotal;
      }

      double averageOrderValue = paidOrdersResponse.isNotEmpty
          ? totalRevenue / paidOrdersResponse.length
          : 0.0;

      print(
        'Week Stats - Total Orders: ${allOrdersResponse.length}, Paid Orders: ${paidOrdersResponse.length}, Revenue: $totalRevenue, AOV: $averageOrderValue',
      );

      setState(() {
        weekStats = {
          'orders': allOrdersResponse.length, // Total orders this week
          'paid_orders': paidOrdersResponse.length, // Paid orders this week
          'revenue': totalRevenue, // Revenue from paid orders
          'average_order_value': averageOrderValue,
        };
      });
    } catch (e) {
      print('Error loading week stats: $e');
      setState(() {
        weekStats = {
          'orders': 0,
          'paid_orders': 0,
          'revenue': 0.0,
          'average_order_value': 0.0,
        };
      });
    }
  }

  Future<void> _loadMonthStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      print(
        'Loading month stats from ${startOfMonth.toIso8601String()} to ${endOfMonth.toIso8601String()}',
      );

      // Get paid or completed orders for this month (count as revenue)
      final paidOrdersResponse = await supabase
          .from('orders')
          .select('total, id, order_status')
          .or('order_status.eq.paid,order_status.eq.completed')
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String());

      // Get all orders for this month
      final allOrdersResponse = await supabase
          .from('orders')
          .select('id, order_status')
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String());

      double totalRevenue = 0;
      for (var order in paidOrdersResponse) {
        double orderTotal = (order['total'] as num?)?.toDouble() ?? 0;
        totalRevenue += orderTotal;
      }

      print(
        'Month Stats - Total Orders: ${allOrdersResponse.length}, Paid Orders: ${paidOrdersResponse.length}, Revenue: $totalRevenue',
      );

      setState(() {
        monthStats = {
          'orders': allOrdersResponse.length, // Total orders this month
          'paid_orders': paidOrdersResponse.length, // Paid orders this month
          'revenue': totalRevenue, // Revenue from paid orders
        };
      });
    } catch (e) {
      print('Error loading month stats: $e');
      setState(() {
        monthStats = {'orders': 0, 'paid_orders': 0, 'revenue': 0.0};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Laporan Penjualan',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Pesanan'),
            Tab(text: 'Analitik'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildOrdersTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today Stats
          _buildSectionHeader('Hari Ini'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  'Pesanan Hari Ini',
                  todayStats['orders']?.toString() ?? '0',
                  '${todayStats['paid_orders']?.toString() ?? '0'} Terbayar',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailedStatCard(
                  'Pendapatan Hari Ini',
                  currencyFormat.format(todayStats['revenue'] ?? 0),
                  'Dari ${todayStats['paid_orders']?.toString() ?? '0'} pesanan',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sales Report Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToSalesReport,
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: Text(
                'Lihat Laporan Penjualan Detail',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Week Stats
          _buildSectionHeader('Minggu Ini'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  'Pesanan Minggu Ini',
                  weekStats['orders']?.toString() ?? '0',
                  '${weekStats['paid_orders']?.toString() ?? '0'} Terbayar',
                  Icons.calendar_view_week,
                  Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailedStatCard(
                  'Pendapatan Minggu Ini',
                  currencyFormat.format(weekStats['revenue'] ?? 0),
                  'Dari ${weekStats['paid_orders']?.toString() ?? '0'} pesanan',
                  Icons.account_balance_wallet,
                  Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // AOV Card - Full Width
          _buildDetailedStatCard(
            'Rata-rata Nilai Pesanan (AOV)',
            currencyFormat.format(weekStats['average_order_value'] ?? 0),
            'Average Order Value minggu ini',
            Icons.analytics,
            Colors.deepPurple,
          ),

          const SizedBox(height: 24),

          // This Month Stats
          _buildSectionHeader('Bulan Ini'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  'Pesanan Bulan Ini',
                  monthStats['orders']?.toString() ?? '0',
                  '${monthStats['paid_orders']?.toString() ?? '0'} Terbayar',
                  Icons.shopping_cart,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailedStatCard(
                  'Pendapatan Bulan Ini',
                  currencyFormat.format(monthStats['revenue'] ?? 0),
                  'Total dari penjualan',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Orders
          _buildSectionHeader('Pesanan Terbaru'),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...orders.take(5).map((order) => _buildOrderCard(order)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Pindah ke tab Pesanan pada laporan penjualan
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.list_alt),
                label: Text(
                  'Lihat Semua Transaksi (${orders.length})',
                  style: TextStyle(
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index]);
              },
            ),
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Trend Penjualan'),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Analitik Segera Hadir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grafik dan analitik detail akan tersedia segera',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
        fontStyle: GoogleFonts.montserrat().fontStyle,
      ),
    );
  }

  Widget _buildDetailedStatCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Real-time',
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final createdAt = DateTime.parse(order['created_at']);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0;
    final status = order['order_status'] ?? order['status'] ?? 'pending';
    final statusInfo = _getStatusInfo(status);
    final statusColor = statusInfo['color'];
    final statusText = statusInfo['text'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['id']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Table Info
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.table_restaurant, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            order['tables']?['table_name'] ?? 'No Table',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Customer Name if available
                  if (order['customer_name'] != null && order['customer_name'].toString().isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order['customer_name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  Text(
                    currencyFormat.format(totalAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to full-screen order detail page
                      Get.to(() => OrderDetailPage(order: order));
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: Text(
                      'Lihat Detail',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final orderItems = order['order_items'] as List? ?? [];
    final userInfo = order['users'] as Map<String, dynamic>?;
    final cashierName =
        userInfo?['full_name'] ?? userInfo?['email'] ?? 'Unknown Cashier';
    final tableInfo = order['tables'] as Map<String, dynamic>?;
    final tableName = tableInfo?['table_name'] ?? 'No Table';
    final createdAt = DateTime.parse(order['created_at']);
    final orderStatus = order['order_status'] ?? 'pending';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cashier Info
                      _buildDetailSection(
                        'Informasi Kasir',
                        Icons.person,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cashierName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tableName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle:
                                        GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateFormat.format(createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle:
                                        GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Order Items
                      _buildDetailSection(
                        'Menu Pesanan',
                        Icons.restaurant_menu,
                        Column(
                          children: orderItems.map<Widget>((item) {
                            final menuData =
                                item['menu'] as Map<String, dynamic>?;
                            final menuName =
                                menuData?['name'] ??
                                item['menu_name'] ??
                                'Menu Tidak Diketahui';
                            final quantity =
                                item['qty'] ?? item['quantity'] ?? 0;
                            final price =
                                (item['price'] as num?)?.toDouble() ?? 0;
                            final subtotal =
                                (item['subtotal'] as num?)?.toDouble() ??
                                (quantity * price);

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menuName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: GoogleFonts.montserrat()
                                                .fontStyle,
                                          ),
                                        ),
                                        Text(
                                          '$quantity x ${currencyFormat.format(price)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: GoogleFonts.montserrat()
                                                .fontStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(subtotal),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontStyle:
                                          GoogleFonts.montserrat().fontStyle,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Order Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal', order['subtotal']),
                            if ((order['service_fee'] ?? 0) > 0)
                              _buildSummaryRow(
                                'Biaya Layanan',
                                order['service_fee'],
                              ),
                            if ((order['tax'] ?? 0) > 0)
                              _buildSummaryRow('Pajak', order['tax']),
                            if ((order['discount'] ?? 0) > 0)
                              _buildSummaryRow(
                                'Diskon',
                                -(order['discount'] ?? 0),
                                isDiscount: true,
                              ),
                            const Divider(thickness: 1.5),
                            _buildSummaryRow(
                              'Total',
                              order['total'],
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _printReceipt(order),
                        icon: const Icon(Icons.print),
                        label: Text(
                          'Cetak Struk',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (orderStatus != 'completed')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markOrderComplete(order),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Selesai',
                            style: TextStyle(
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }

  Widget _buildDetailSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    dynamic amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          Text(
            currencyFormat.format((amount as num?)?.toDouble() ?? 0),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? Theme.of(context).primaryColor
                  : Colors.black,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(Map<String, dynamic> orderData) async {
    try {
      Get.back(); // Close dialog first

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Convert to OrderModel for receipt service
      final order = await _orderService.getOrderById(orderData['id']);

      if (order != null) {
        await _receiptService.printReceipt(order);
        Get.back(); // Close loading

        Get.snackbar(
          'Berhasil',
          'Struk berhasil dicetak',
          backgroundColor: Colors.green[700],
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.back(); // Close loading
        throw Exception('Order not found');
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> _markOrderComplete(Map<String, dynamic> orderData) async {
    try {
      // Show confirmation dialog
      final confirmed =
          await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 12),
                  Text(
                    'Konfirmasi',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Tandai pesanan #${orderData['id']} sebagai selesai?',
                style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ya, Selesai',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;

      Get.back(); // Close details dialog

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Update order status (try completed first, fallback to paid if constraint fails)
      try {
        await _orderService.updateOrderStatus(orderData['id'], 'completed');
      } catch (e) {
        // If completed status is not allowed, use paid as completed status
        if (e.toString().contains('check constraint') ||
            e.toString().contains('orderstatus')) {
          await _orderService.updateOrderStatus(orderData['id'], 'paid');
        } else {
          rethrow;
        }
      }

      // If order has table, mark as reserved (kitchen finished, waiting cashier)
      if (orderData['table_id'] != null) {
        await supabase
            .from('tables')
            .update({'status': 'reserved'})
            .eq('id', orderData['table_id']);
      }

      Get.back(); // Close loading

      Get.snackbar(
        'Berhasil',
        'Pesanan #${orderData['id']} telah diselesaikan',
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Reload data
      _loadData();
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan pesanan: $e',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
