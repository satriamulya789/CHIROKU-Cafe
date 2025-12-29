import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;

  int totalUsers = 0;
  int totalMenu = 0;
  int totalTables = 0;
  int todayOrders = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final users = await getTotalUsers();
    final menu = await getTotalMenu();
    final tables = await getTotalTables();
    final orders = await getTodayOrders();

    setState(() {
      totalUsers = users;
      totalMenu = menu;
      totalTables = tables;
      todayOrders = orders;
      isLoading = false;
    });
  }

  Future<int> getTotalUsers() async {
    final data = await supabase.from('users').select('id');
    return data.length;
  }

  Future<int> getTotalMenu() async {
    final data = await supabase.from('menu').select('id');
    return data.length;
  }

  Future<int> getTotalTables() async {
    final data = await supabase.from('tables').select('id');
    return data.length;
  }

  Future<int> getTodayOrders() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final data = await supabase
        .from('orders')
        .select('id')
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String());

    return data.length;
  }

  Widget dashboardCard({
    required Color color,
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white, 
                fontStyle: GoogleFonts.montserrat().fontStyle,
                fontWeight: FontWeight.w500
              ),
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
  
          ),
          Icon(icon, size: 50, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Dashboard")),
      // body: isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : Padding(
      //         padding: const EdgeInsets.all(16),
      //         child: GridView.count(
      //           crossAxisCount: 2,
      //           crossAxisSpacing: 16,
      //           mainAxisSpacing: 16,
      //           childAspectRatio: 1.8,
      //           children: [
      //             dashboardCard(
      //               color: Colors.green,
      //               title: "Total Users",
      //               value: totalUsers,
      //               icon: Icons.people,
      //             ),
      //             dashboardCard(
      //               color: Colors.blue,
      //               title: "Menu Items",
      //               value: totalMenu,
      //               icon: Icons.restaurant_menu,
      //             ),
      //             dashboardCard(
      //               color: Colors.orange,
      //               title: "Total Tables",
      //               value: totalTables,
      //               icon: Icons.table_restaurant,
      //             ),
      //             dashboardCard(
      //               color: Colors.purple,
      //               title: "Today Orders",
      //               value: todayOrders,
      //               icon: Icons.receipt_long,
      //             ),
      //           ],
      //         ),
      //       ),
    );
  }
}
