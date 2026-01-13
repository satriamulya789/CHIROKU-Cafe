

import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/repositories/cashier_order_cart_repositories.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/repositories/cashier_order_menu_repositories.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderController extends GetxController {
  // Repositories
  final MenuRepository _menuRepository = MenuRepository();
  final CartRepository _cartRepository = CartRepository();

  // Observables - Data
  final RxList<MenuModel> menus = <MenuModel>[].obs;
  final RxList<MenuModel> filteredMenus = <MenuModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Observables - UI State
  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt cartCount = 0.obs;

  // Observables - Item Quantities (for quantity selector before adding to cart)
  final RxMap<String, int> itemQuantities = <String, int>{}.obs;

  // Selected table (optional - passed from table management)
  final Rx<TableModel?> selectedTable = Rx<TableModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeArguments();
    loadData();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize arguments from previous screen
  void _initializeArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('table')) {
      selectedTable.value = args['table'] as TableModel?;
    }
  }

  // ==================== DATA LOADING ====================

  /// Load initial data (categories and menus)
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Load categories and menus in parallel
      final results = await Future.wait([
        _menuRepository.getCategories(),
        _menuRepository.getMenus(),
      ]);

      categories.value = results[0] as List<CategoryModel>;
      menus.value = results[1] as List<MenuModel>;
      filteredMenus.value = results[1] as List<MenuModel>;

      // Update cart count
      await updateCartCount();
    } catch (e) {
      _showErrorSnackbar('Failed to load menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data (for pull-to-refresh)
  Future<void> refreshData() async {
    await loadData();
  }

  // ==================== FILTERING ====================

  /// Filter menus based on search query and category
  void filterMenus() {
    filteredMenus.value = _menuRepository.filterMenus(
      menus: menus.value,
      searchQuery: searchQuery.value,
      categoryName: selectedCategory.value,
    );
  }

  /// Set search query and trigger filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterMenus();
  }

  /// Set selected category and trigger filter
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    filterMenus();
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    filterMenus();
  }

  // ==================== QUANTITY MANAGEMENT ====================

  /// Increase quantity for a menu item
  void increaseQuantity(String menuId) {
    itemQuantities[menuId] = (itemQuantities[menuId] ?? 1) + 1;
  }

  /// Decrease quantity for a menu item
  void decreaseQuantity(String menuId) {
    final currentQty = itemQuantities[menuId] ?? 1;
    if (currentQty > 1) {
      itemQuantities[menuId] = currentQty - 1;
    }
  }

  /// Get current quantity for a menu item
  int getQuantity(String menuId) {
    return itemQuantities[menuId] ?? 1;
  }

  /// Reset quantity for a menu item
  void resetQuantity(String menuId) {
    itemQuantities[menuId] = 1;
  }

  // ==================== CART OPERATIONS ====================

  /// Add menu item to cart
  Future<void> addToCart(MenuModel menu) async {
    try {
      // Check if item is available
      if (!menu.isAvailable) {
        _showWarningSnackbar('${menu.name} is not available');
        return;
      }

      final quantity = getQuantity(menu.id.toString());

      // Add to cart via repository
      await _cartRepository.addToCart(
        productId: menu.id.toString(),
        productName: menu.name,
        price: menu.price,
        category: menu.category?.name,
        imageUrl: menu.imageUrl,
        quantity: quantity,
      );

      // Reset quantity to 1 after adding
      resetQuantity(menu.id.toString());

      // Update cart count
      await updateCartCount();

      // Show success message
      _showSuccessSnackbar(
        '$quantity x ${menu.name} added to cart',
        showViewCartAction: true,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to add to cart: $e');
    }
  }

  /// Update cart count
  Future<void> updateCartCount() async {
    try {
      cartCount.value = await _cartRepository.getCartCount();
    } catch (e) {
      cartCount.value = 0;
    }
  }

  // ==================== NAVIGATION ====================

  /// Navigate to cart page
  void navigateToCart() {
    if (selectedTable.value != null) {
      Get.toNamed(
        '/cashier/cart',
        arguments: {'table': selectedTable.value},
      )?.then((_) => updateCartCount());
    } else {
      Get.toNamed('/cashier/cart')?.then((_) => updateCartCount());
    }
  }

  /// Navigate to menu detail (optional)
  void navigateToMenuDetail(MenuModel menu) {
    Get.toNamed('/cashier/menu-detail', arguments: {'menu': menu});
  }

  // ==================== SNACKBAR HELPERS ====================

  void _showSuccessSnackbar(String message, {bool showViewCartAction = false}) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Get.theme.colorScheme.onSecondary,
      mainButton: showViewCartAction
          ? TextButton(
              onPressed: navigateToCart,
              child: const Text('VIEW CART'),
            )
          : null,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void _showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.tertiary,
      colorText: Get.theme.colorScheme.onTertiary,
    );
  }

  // ==================== LIFECYCLE ====================

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}