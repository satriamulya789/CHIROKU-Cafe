import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'all_transactions_page.dart'; // Import the new page for all transactions

class ReportAdmin extends StatefulWidget {
  const ReportAdmin({super.key});

  @override
  State<ReportAdmin> createState() => _ReportAdminState();
}

class _ReportAdminState extends State<ReportAdmin> {
  final supabase = Supabase.instance.client;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  bool _isDailySalesExpanded = true;
  bool _isCashierPerformanceExpanded = true;

  // Statistics Data
  int _totalOrders = 0;
  double _totalRevenue = 0;
  double _avgRevenue = 0;
  int _itemsSold = 0;

  // Filter
  String _selectedFilter = 'today'; // today, week, month, all
  DateTimeRange? _customDateRange;
  String? _selectedCashierId; // null = All Cashiers

  // Charts & Lists Data
  List<Map<String, dynamic>> _dailySalesData = [];
  List<Map<String, dynamic>> _top10Items = [];
  List<Map<String, dynamic>> _recentTransactions = [];
  List<Map<String, dynamic>> _cashierPerformance = [];
  List<Map<String, dynamic>> _cashierList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadCashierList();
    await _loadReportData();
  }

  Future<void> _loadCashierList() async {
    try {
      // Load all users who have made orders (cashiers)
      final result = await supabase
          .from('orders')
          .select('user_id, users!orders_user_id_fkey(id, full_name, email)')
          .not('user_id', 'is', null);

      // Get unique cashiers
      final Map<String, Map<String, dynamic>> uniqueCashiers = {};
      for (var order in result) {
        final user = order['users'];
        if (user != null) {
          final userId = user['id'];
          uniqueCashiers[userId] = {
            'id': userId,
            'full_name': user['full_name'],
            'email': user['email'],
          };
        }
      }

      setState(() {
        _cashierList = uniqueCashiers.values.toList();
      });
    } catch (e) {
      debugPrint('Error loading cashier list: $e');
      // Fallback: try to get users directly
      try {
        final fallbackResult = await supabase
            .from('users')
            .select('id, full_name, email');

        setState(() {
          _cashierList = List<Map<String, dynamic>>.from(fallbackResult);
        });
      } catch (e2) {
        debugPrint('Fallback cashier list failed: $e2');
      }
    }
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadStatistics(),
        _loadDailySales(),
        _loadTop10Items(),
        _loadRecentTransactions(),
        if (_selectedCashierId == null) _loadCashierPerformance(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month, 1);
      case 'custom':
        return _customDateRange?.start ?? now;
      default:
        return DateTime(2000);
    }
  }

  DateTime _getEndDate() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'today':
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case 'custom':
        return _customDateRange?.end ?? now;
      default:
        return now;
    }
  }

  Future<void> _loadStatistics() async {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    debugPrint('📊 Loading statistics from $startDate to $endDate');
    debugPrint('📊 Selected filter: $_selectedFilter');
    debugPrint('📊 Selected cashier: $_selectedCashierId');

    try {
      // Query untuk ambil orders yang completed/paid saja menggunakan or filter
      var query = supabase
          .from('orders')
          .select('id, total, order_status, created_at, user_id')
          .or('order_status.eq.paid,order_status.eq.completed')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Add cashier filter if selected
      if (_selectedCashierId != null) {
        query = query.eq('user_id', _selectedCashierId!);
      }

      final orders = await query;

      debugPrint('📊 Found ${orders.length} orders');

      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(0.0, (sum, order) {
        final total = order['total'];
        if (total == null) return sum;
        return sum + (total is num ? total.toDouble() : 0.0);
      });

      debugPrint('📊 Total Revenue: $totalRevenue');

      final avgRevenue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      // Items Sold - Get order IDs and fetch order_items
      final orderIds = orders
          .map((o) => o['id'] ?? 0)
          .where((id) => id != 0)
          .toList();

      debugPrint('📊 Order IDs: $orderIds');

      int itemsSold = 0;
      if (orderIds.isNotEmpty) {
        try {
          // Build OR condition for order_id filtering
          final orConditions = orderIds
              .map((id) => 'order_id.eq.$id')
              .join(',');

          final itemsData = await supabase
              .from('order_items')
              .select('qty')
              .or(orConditions);

          debugPrint('📊 Found ${itemsData.length} order items');

          itemsSold = itemsData.fold<int>(0, (sum, item) {
            final qty = item['qty'];
            return sum + (qty is int ? qty : 0);
          });

          debugPrint('📊 Items Sold: $itemsSold');
        } catch (itemsError) {
          debugPrint('❌ Error loading items sold: $itemsError');
        }
      }

      if (mounted) {
        setState(() {
          _totalOrders = totalOrders;
          _totalRevenue = totalRevenue;
          _avgRevenue = avgRevenue;
          _itemsSold = itemsSold;
        });
        debugPrint('✅ Statistics updated in UI');
      }
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _totalOrders = 0;
          _totalRevenue = 0.0;
          _avgRevenue = 0.0;
          _itemsSold = 0;
        });
      }
    }
  }

  Future<void> _loadDailySales() async {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    try {
      PostgrestFilterBuilder query = supabase
          .from('orders')
          .select('id, total, created_at, user_id')
          .inFilter('order_status', ['paid', 'completed'])
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (_selectedCashierId != null) {
        query = query.eq('user_id', _selectedCashierId!);
      }

      final orders = await query.order('created_at', ascending: false);

      // Group by date
      final Map<String, Map<String, dynamic>> grouped = {};
      for (var order in orders) {
        final date = DateTime.parse(order['created_at']);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (grouped.containsKey(dateKey)) {
          grouped[dateKey]!['total_orders'] += 1;
          grouped[dateKey]!['total_revenue'] +=
              (order['total'] as num?)?.toDouble() ?? 0.0;
        } else {
          grouped[dateKey] = {
            'sale_date': dateKey,
            'total_orders': 1,
            'total_revenue': (order['total'] as num?)?.toDouble() ?? 0.0,
          };
        }
      }

      // Convert to list and sort
      final result = grouped.values.toList()
        ..sort(
          (a, b) =>
              (b['sale_date'] as String).compareTo(a['sale_date'] as String),
        );

      if (mounted) {
        setState(() {
          _dailySalesData = result;
        });
      }
    } catch (e) {
      debugPrint('Error loading daily sales: $e');
      if (mounted) {
        setState(() {
          _dailySalesData = [];
        });
      }
    }
  }

  Future<void> _loadTop10Items() async {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    try {
      // Get order IDs yang sudah completed/paid
      PostgrestFilterBuilder ordersQuery = supabase
          .from('orders')
          .select('id')
          .inFilter('order_status', ['paid', 'completed'])
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (_selectedCashierId != null) {
        ordersQuery = ordersQuery.eq('user_id', _selectedCashierId!);
      }

      final orders = await ordersQuery;
      final orderIds = orders.map((o) => o['id']).toList();

      if (orderIds.isEmpty) {
        if (mounted) {
          setState(() => _top10Items = []);
        }
        return;
      }

      final result = await supabase
          .from('order_items')
          .select('menu_id, qty, menu!inner(name, price)')
          .inFilter('order_id', orderIds);

      // Group by menu_id and sum qty
      final Map<int, Map<String, dynamic>> grouped = {};
      for (var item in result) {
        final menuId = item['menu_id'] as int;
        final qty = item['qty'] as int;
        final menu = item['menu'];

        if (grouped.containsKey(menuId)) {
          grouped[menuId]!['total_qty'] += qty;
          grouped[menuId]!['total_revenue'] +=
              qty * (menu['price'] as num).toDouble();
        } else {
          grouped[menuId] = {
            'menu_id': menuId,
            'name': menu['name'],
            'price': (menu['price'] as num).toDouble(),
            'total_qty': qty,
            'total_revenue': qty * (menu['price'] as num).toDouble(),
          };
        }
      }

      final sortedItems = grouped.values.toList()
        ..sort(
          (a, b) => (b['total_qty'] as int).compareTo(a['total_qty'] as int),
        );

      if (mounted) {
        setState(() {
          _top10Items = sortedItems.take(10).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading top 10 items: $e');
      if (mounted) {
        setState(() {
          _top10Items = [];
        });
      }
    }
  }

  Future<void> _loadRecentTransactions() async {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    try {
      // Query untuk transaksi terbaru dari cashier
      PostgrestFilterBuilder query = supabase
          .from('orders')
          .select('''
            id,
            total,
            order_status,
            created_at,
            table_id,
            user_id,
            customer_name,
            tables(table_name),
            payments(payment_method),
            users!orders_user_id_fkey(full_name, email)
          ''')
          .inFilter('order_status', ['paid', 'completed'])
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (_selectedCashierId != null) {
        query = query.eq('user_id', _selectedCashierId!);
      }

      final result = await query
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _recentTransactions = List<Map<String, dynamic>>.from(result);
        });
      }
    } catch (relationError) {
      debugPrint('User relation failed, trying fallback: $relationError');

      // Fallback query tanpa user relation
      try {
        PostgrestFilterBuilder query = supabase
            .from('orders')
            .select('''
              id,
              total,
              order_status,
              created_at,
              table_id,
              user_id,
              customer_name,
              tables(table_name),
              payments(payment_method)
            ''')
            .inFilter('order_status', ['paid', 'completed'])
            .gte('created_at', startDate.toIso8601String())
            .lte('created_at', endDate.toIso8601String());

        if (_selectedCashierId != null) {
          query = query.eq('user_id', _selectedCashierId!);
        }

        final result = await query
            .order('created_at', ascending: false)
            .limit(5);

        if (mounted) {
          setState(() {
            _recentTransactions = List<Map<String, dynamic>>.from(result);
          });
        }
      } catch (e) {
        debugPrint('Error loading recent transactions: $e');
        if (mounted) {
          setState(() {
            _recentTransactions = [];
          });
        }
      }
    }
  }

  Future<void> _loadCashierPerformance() async {
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    try {
      // Get semua orders dalam periode
      final allOrders = await supabase
          .from('orders')
          .select(
            'id, total, user_id, users!orders_user_id_fkey(id, full_name, email)',
          )
          .inFilter('order_status', ['paid', 'completed'])
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .not('user_id', 'is', null);

      // Group by cashier
      final Map<String, Map<String, dynamic>> cashierStats = {};

      for (var order in allOrders) {
        final userId = order['user_id'];
        final user = order['users'];

        if (userId == null || user == null) continue;

        final userIdStr = userId.toString();
        final cashierName = user['full_name'] ?? user['email'] ?? 'Unknown';
        final total = (order['total'] as num?)?.toDouble() ?? 0.0;

        if (cashierStats.containsKey(userIdStr)) {
          cashierStats[userIdStr]!['total_orders'] += 1;
          cashierStats[userIdStr]!['total_revenue'] += total;
        } else {
          cashierStats[userIdStr] = {
            'cashier_id': userId,
            'cashier_name': cashierName,
            'total_orders': 1,
            'total_revenue': total,
            'items_sold': 0,
          };
        }
      }

      // Get items sold for each cashier
      for (var entry in cashierStats.entries) {
        final cashierId = entry.value['cashier_id'];

        try {
          final cashierOrders = await supabase
              .from('orders')
              .select('id')
              .eq('user_id', cashierId)
              .inFilter('order_status', ['paid', 'completed'])
              .gte('created_at', startDate.toIso8601String())
              .lte('created_at', endDate.toIso8601String());

          final orderIds = cashierOrders.map((o) => o['id']).toList();

          if (orderIds.isNotEmpty) {
            final items = await supabase
                .from('order_items')
                .select('qty')
                .inFilter('order_id', orderIds);

            final itemsSold = items.fold<int>(
              0,
              (sum, item) => sum + ((item['qty'] as int?) ?? 0),
            );

            entry.value['items_sold'] = itemsSold;
          }
        } catch (e) {
          debugPrint('Error loading items for cashier ${entry.key}: $e');
        }
      }

      // Convert to list and sort by revenue
      final performance = cashierStats.values.toList()
        ..sort(
          (a, b) => (b['total_revenue'] as double).compareTo(
            a['total_revenue'] as double,
          ),
        );

      if (mounted) {
        setState(() {
          _cashierPerformance = performance;
        });
      }
    } catch (e) {
      debugPrint('Error loading cashier performance: $e');
      if (mounted) {
        setState(() {
          _cashierPerformance = [];
        });
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = 'custom';
      });
      _loadReportData();
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontStyle: GoogleFonts.montserrat().fontStyle,
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _loadReportData();
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildCashierFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedCashierId,
          isExpanded: true,
          hint: Text(
            'Semua Kasir',
            style: TextStyle(
              fontStyle: GoogleFonts.montserrat().fontStyle,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).primaryColor,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Semua Kasir',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ..._cashierList.map((cashier) {
              return DropdownMenuItem<String?>(
                value: cashier['id'],
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cashier['full_name'] ?? cashier['email'] ?? 'Unknown',
                        style: TextStyle(
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() => _selectedCashierId = value);
            _loadReportData();
          },
        ),
      ),
    );
  }

  Widget _buildDailySalesChart() {
    if (_dailySalesData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Belum ada data penjualan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxRevenue = _dailySalesData.fold<double>(0.0, (max, data) {
      final revenue = data['total_revenue'];
      if (revenue == null) return max;
      final revenueDouble = revenue is num ? revenue.toDouble() : 0.0;
      return revenueDouble > max ? revenueDouble : max;
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailySalesData.length,
      itemBuilder: (context, index) {
        final data = _dailySalesData[index];
        final date = DateTime.parse(data['sale_date']);

        final revenueValue = data['total_revenue'];
        final revenue = revenueValue is num ? revenueValue.toDouble() : 0.0;

        final ordersValue = data['total_orders'];
        final orders = ordersValue is int ? ordersValue : 0;

        final percentage = maxRevenue > 0 ? revenue / maxRevenue : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                  Text(
                    '$orders pesanan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: Text(
                      currencyFormat.format(revenue),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCashierPerformance() {
    if (_cashierPerformance.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.people, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Belum ada data kasir',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cashierPerformance.length,
      itemBuilder: (context, index) {
        final cashier = _cashierPerformance[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? (rank == 1
                          ? Colors.amber
                          : rank == 2
                          ? Colors.grey[400]
                          : Colors.brown[300])
                    : Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : Colors.blue[900],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ),
            ),
            title: Text(
              cashier['cashier_name'] ?? 'Unknown',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            subtitle: Text(
              '${cashier['total_orders']} pesanan • ${cashier['items_sold']} item terjual',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(cashier['total_revenue']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Text(
                  'Pendapatan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTop10Items() {
    if (_top10Items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inventory_2, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Belum ada item terjual',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _top10Items.length,
      itemBuilder: (context, index) {
        final item = _top10Items[index];
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? (rank == 1
                          ? Colors.amber
                          : rank == 2
                          ? Colors.grey[400]
                          : Colors.brown[300])
                    : Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : Colors.blue[900],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ),
            ),
            title: Text(
              item['name'] ?? 'Unknown Item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            subtitle: Text(
              '${item['total_qty']} terjual • ${currencyFormat.format(item['price'])} per item',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(item['total_revenue']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Text(
                  'Pendapatan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _recentTransactions[index];
        final createdAt = DateTime.parse(transaction['created_at']);
        final table = transaction['tables'];
        final payments = transaction['payments'] as List?;
        final paymentMethod = payments?.isNotEmpty == true
            ? payments!.first['payment_method']
            : 'cash';

        // Get cashier name dari users relation
        final users = transaction['users'];
        final cashierName = users != null
            ? (users['full_name'] ?? users['email'] ?? 'Unknown Cashier')
            : 'System';

        // Get customer name
        final customerName = transaction['customer_name'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                paymentMethod == 'cash'
                    ? Icons.money
                    : paymentMethod == 'qris'
                    ? Icons.qr_code
                    : Icons.credit_card,
                color: Colors.green[700],
                size: 20,
              ),
            ),
            title: Text(
              'Pesanan #${transaction['id']}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${table != null ? 'Meja ${table['table_name'] ?? table['table_number'] ?? transaction['table_id']}' : 'Tanpa Meja'} • ${DateFormat('dd MMM, HH:mm').format(createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Text(
                  'Kasir: $cashierName',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (customerName != null && customerName.isNotEmpty)
                  Text(
                    'Customer: $customerName',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple[700],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction['total']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.green[700],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paymentMethod.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Laporan Penjualan (Admin)',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Grid
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Pesanan',
                                value: _totalOrders.toString(),
                                icon: Icons.shopping_bag,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Pendapatan',
                                value: currencyFormat.format(_totalRevenue),
                                icon: Icons.account_balance_wallet,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Rata-rata Pendapatan',
                                value: currencyFormat.format(_avgRevenue),
                                icon: Icons.trending_up,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Item Terjual',
                                value: _itemsSold.toString(),
                                icon: Icons.inventory_2,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Cashier Filter
                    Text(
                      'Filter berdasarkan Kasir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCashierFilter(),

                    const SizedBox(height: 24),

                    // Filter Section
                    Text(
                      'Filter Waktu Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('Hari Ini', 'today'),
                        _buildFilterChip('7 Hari Terakhir', 'week'),
                        _buildFilterChip('Bulan Ini', 'month'),
                        _buildFilterChip('Semua Waktu', 'all'),
                        FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.date_range, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _selectedFilter == 'custom' &&
                                        _customDateRange != null
                                    ? '${DateFormat('dd/MM').format(_customDateRange!.start)} - ${DateFormat('dd/MM').format(_customDateRange!.end)}'
                                    : 'Custom',
                                style: TextStyle(
                                  fontStyle: GoogleFonts.montserrat().fontStyle,
                                  color: _selectedFilter == 'custom'
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          selected: _selectedFilter == 'custom',
                          onSelected: (selected) => _selectDateRange(),
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Cashier Performance (Only show if no cashier filter)
                    if (_selectedCashierId == null) ...[
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(
                                  () => _isCashierPerformanceExpanded =
                                      !_isCashierPerformanceExpanded,
                                );
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Performa Kasir',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: GoogleFonts.montserrat()
                                              .fontStyle,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _isCashierPerformanceExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isCashierPerformanceExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: _buildCashierPerformance(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Daily Sales Chart (Expandable)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () => _isDailySalesExpanded =
                                    !_isDailySalesExpanded,
                              );
                            },
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Penjualan Harian',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontStyle:
                                            GoogleFonts.montserrat().fontStyle,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _isDailySalesExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isDailySalesExpanded) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildDailySalesChart(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Top 10 Items
                    Text(
                      'Top 10 Item Terlaris',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTop10Items(),

                    const SizedBox(height: 24),

                    // Recent Transactions
                    Text(
                      'Transaksi Terbaru dari Kasir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(),

                    // Button to view all transactions in a new page
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllTransactionsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt, color: Colors.white),
                        label: Text(
                          'Lihat Semua Transaksi',
                          style: TextStyle(
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    // Extra spacing at bottom
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
