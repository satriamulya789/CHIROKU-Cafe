import 'package:chiroku_cafe/shared/repositories/auth/auth_service.dart';
import 'package:chiroku_cafe/shared/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdmin extends StatefulWidget {
  final bool showAppBar;
  
  const HomeAdmin({super.key, this.showAppBar = true});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  String _fullName = '';
  String? _avatarUrl;
  UserModel? currentUser;

  int totalUsers = 0;
  int totalMenu = 0;
  int totalTables = 0;
  int todayOrders = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      // Load user data dari AuthService (untuk backward compatibility)
      final fullName = await _authService.getUserFullName();
      final avatarUrl = await _authService.getUserAvatarUrl();
      
      // Load current user details dari Supabase
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final userData = await supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .single();
          currentUser = UserModel.fromJson(userData);
        } catch (e) {
          print('Error loading user model: $e');
        }
      }

      // Load stats dengan proper error handling
      final usersData = await supabase.from('users').select('id');
      final menuData = await supabase.from('menu').select('id');
      final tablesData = await supabase.from('tables').select('id');

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));

      // Try to load orders, handle if table doesn't exist
      int ordersCount = 0;
      try {
        final ordersData = await supabase
            .from('orders')
            .select('id')
            .gte('created_at', start.toIso8601String())
            .lt('created_at', end.toIso8601String());
        ordersCount = ordersData.length;
      } catch (e) {
        print('Orders table not ready yet: $e');
        ordersCount = 0;
      }

      if (mounted) {
        setState(() {
          _fullName = fullName ?? currentUser?.fullName ?? 'Admin';
          _avatarUrl = avatarUrl ?? currentUser?.avatarUrl;
          totalUsers = usersData.length;
          totalMenu = menuData.length;
          totalTables = tablesData.length;
          todayOrders = ordersCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _fullName = 'Admin';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileAvatar() {
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(_avatarUrl!),
        backgroundColor: Colors.grey[300],
        onBackgroundImageError: (exception, stackTrace) {
          setState(() => _avatarUrl = null);
        },
      );
    } else {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.brown.shade100,
        child: Icon(
          Icons.person,
          size: 20,
          color: Colors.brown.shade600,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/icon/logoo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chiroku Cafe',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications coming soon!')),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: _buildProfileAvatar(),
                    onPressed: () {
                      Get.toNamed('/settings');
                    },
                  ),
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header (hanya tampil jika tidak ada AppBar)
                    if (!widget.showAppBar)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.brown.shade100,
                            backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _avatarUrl == null || _avatarUrl!.isEmpty
                                ? const Icon(Icons.person, color: Colors.brown, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontStyle: GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                                Text(
                                  _fullName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: GoogleFonts.montserrat().fontStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.toNamed('/settings'),
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),

                    if (!widget.showAppBar) const SizedBox(height: 24),

                    // Main Welcome Text
                    Text(
                      "Welcome, $_fullName!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You are logged in as Admin",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dashboard Stats Grid
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Users',
                          totalUsers.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Menu Items',
                          totalMenu.toString(),
                          Icons.restaurant_menu,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Total Tables',
                          totalTables.toString(),
                          Icons.table_restaurant,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Today Orders',
                          todayOrders.toString(),
                          Icons.receipt_long,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Admin Controls',
                            'Manage users, tables & menu',
                            Icons.admin_panel_settings,
                            Colors.indigo,
                            () => Get.toNamed('/admin/controls'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'View Reports',
                            'Sales & analytics',
                            Icons.analytics,
                            Colors.teal,
                            () => Get.snackbar('Info', 'Reports coming soon!'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Management Sections
                    Text(
                      'Management Sections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildManagementTile(
                      'User Management',
                      'Add, edit, and manage staff accounts',
                      Icons.people_outline,
                      Colors.blue,
                      () => Get.toNamed('/admin/controller?tab=0'),
                    ),

                    _buildManagementTile(
                      'Table Management',
                      'Configure restaurant tables and seating',
                      Icons.table_restaurant_outlined,
                      Colors.green,
                      () => Get.toNamed('/admin/controller?tab=1'),
                    ),

                    _buildManagementTile(
                      'Menu Management',
                      'Update food and beverage items',
                      Icons.restaurant_menu_outlined,
                      Colors.orange,
                      () => Get.toNamed('/admin/controller?tab=2'),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}