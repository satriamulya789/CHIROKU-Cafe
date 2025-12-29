import 'package:chiroku_cafe/shared/models/menu_models.dart';
import 'package:chiroku_cafe/shared/models/table_models.dart';
import 'package:chiroku_cafe/shared/repositories/cart/cart_service.dart';
import 'package:chiroku_cafe/shared/repositories/menu/menu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final MenuService _menuService = MenuService();
  final CartService _cartService = CartService();
  final TextEditingController _searchController = TextEditingController();

  List<MenuModel> menus = [];
  List<MenuModel> filteredMenus = [];
  List<Map<String, dynamic>> categories = [];
  String selectedCategory = 'all';
  bool isLoading = false;
  TableModel? selectedTable;
  int cartCount = 0;

  // Track quantity for each menu item
  Map<String, int> itemQuantities = {};

  @override
  void initState() {
    super.initState();
    // Get table from arguments if provided
    selectedTable = null;

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final categoriesData = await _menuService.getCategories();
      final menusData = await _menuService.getMenus();
      final count = await _cartService.getCartCount();

      setState(() {
        categories = categoriesData;
        menus = menusData;
        filteredMenus = menusData;
        cartCount = count;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterMenus() {
    setState(() {
      filteredMenus = menus.where((menu) {
        final matchesSearch = menu.name.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        final matchesCategory =
            selectedCategory == 'all' || menu.categoryName == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _addToCart(MenuModel menu) async {
    try {
      final quantity = itemQuantities[menu.id.toString()] ?? 1;

      await _cartService.addToCart(
        productId: menu.id.toString(),
        productName: menu.name,
        price: menu.price,
        category: menu.categoryName,
        imageUrl: menu.imageUrl,
        quantity: quantity,
      );

      // Reset quantity to 1 after adding
      setState(() {
        itemQuantities[menu.id.toString()] = 1;
      });

      // Update cart count
      final count = await _cartService.getCartCount();
      setState(() => cartCount = count);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$quantity x ${menu.name} added to cart',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                if (selectedTable != null) {
                  Get.toNamed(
                    '/cashier/cart',
                    arguments: {'table': selectedTable},
                  );
                } else {
                  Get.toNamed('/cashier/cart');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _increaseQuantity(String menuId) {
    setState(() {
      itemQuantities[menuId] = (itemQuantities[menuId] ?? 1) + 1;
    });
  }

  void _decreaseQuantity(String menuId) {
    setState(() {
      final currentQty = itemQuantities[menuId] ?? 1;
      if (currentQty > 1) {
        itemQuantities[menuId] = currentQty - 1;
      }
    });
  }

  int _getQuantity(String menuId) {
    return itemQuantities[menuId] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          selectedTable != null
              ? 'Order - ${selectedTable?.tableName ?? "Table"}'
              : 'Browse Menu',
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  if (selectedTable != null) {
                    await Get.toNamed(
                      '/cashier/cart',
                      arguments: {'table': selectedTable},
                    );
                  } else {
                    await Get.toNamed('/cashier/cart');
                  }
                  _loadData();
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : cartCount.toString(),
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
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterMenus(),
              style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
              decoration: InputDecoration(
                hintText: 'Search menu...',
                hintStyle: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterMenus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('all', 'All'),
                ...categories.map(
                  (cat) => _buildCategoryChip(
                    cat['name'],
                    cat['name'].toString().toUpperCase(),
                  ),
                ),
              ],
            ),
          ),

          // Menu Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMenus.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filteredMenus.length,
                      itemBuilder: (context, index) {
                        return _buildMenuCard(filteredMenus[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                if (selectedTable != null) {
                  Get.toNamed(
                    '/cashier/cart',
                    arguments: {'table': selectedTable},
                  );
                } else {
                  Get.toNamed('/cashier/cart');
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                'View Cart ($cartCount)',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            fontStyle: GoogleFonts.montserrat().fontStyle,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = value;
            _filterMenus();
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300] ?? Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image:
                            menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(menu.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: menu.imageUrl == null || menu.imageUrl!.isEmpty
                          ? Center(
                              child: Icon(
                                menu.categoryName == 'food'
                                    ? Icons.restaurant
                                    : Icons.local_cafe,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            )
                          : null,
                    ),
                    if (menu.categoryName != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: menu.categoryName == 'food'
                                ? Colors.orange
                                : Colors.brown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            menu.categoryDisplayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and Description
                      Text(
                        menu.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (menu.description != null &&
                          menu.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          menu.description ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),

                      // Price
                      Text(
                        currencyFormat.format(menu.price),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Quantity controls and add to cart button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity controls
                          Flexible(
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _decreaseQuantity(menu.id.toString()),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${_getQuantity(menu.id.toString())}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontStyle:
                                            GoogleFonts.montserrat().fontStyle,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _increaseQuantity(menu.id.toString()),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.add,
                                        size: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Add to cart button
                          InkWell(
                            onTap: () => _addToCart(menu),
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No menu found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }
}
