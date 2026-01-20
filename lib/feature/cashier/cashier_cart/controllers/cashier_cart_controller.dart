import 'dart:developer';

import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/discount_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/repositories/cashier_cart_repositories.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/services/discount_service.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final CartRepository _repository = CartRepository();
  final DiscountService _discountService = DiscountService();
  final CustomSnackbar _snackbar = CustomSnackbar();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxList<DiscountModel> availableDiscounts = <DiscountModel>[].obs;
  final Rx<DiscountModel?> selectedDiscount = Rx<DiscountModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDiscounts = false.obs;
  final RxString orderNote = ''.obs;

  // Computed values
  double get subtotal => _repository.calculateSubtotal(cartItems);
  double get taxAmount => _repository.calculateTax(subtotal);

  double get discountAmount {
    if (selectedDiscount.value == null) return 0.0;
    return selectedDiscount.value!.calculateDiscount(subtotal);
  }

  double get total => _repository.calculateTotal(
    subtotal: subtotal,
    tax: taxAmount,
    discount: discountAmount,
  );

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
    fetchDiscounts();
  }

  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

      if (userId.isEmpty) {
        log('⚠️ No user logged in');
        return;
      }

      final items = await _repository.getCartItems(userId);
      cartItems.assignAll(items);
      log('✅ Cart items loaded: ${items.length}');
    } catch (e) {
      log('❌ Error fetching cart items: $e');
      _snackbar.showErrorSnackbar('Failed to load cart items');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDiscounts() async {
    try {
      isLoadingDiscounts.value = true;
      final discountsData = await _discountService.getActiveDiscounts();
      availableDiscounts.assignAll(
        discountsData.map((e) => DiscountModel.fromJson(e)).toList(),
      );
      log('✅ Discounts loaded: ${availableDiscounts.length}');
    } catch (e) {
      log('❌ Error fetching discounts: $e');
    } finally {
      isLoadingDiscounts.value = false;
    }
  }

  Future<void> addToCart(MenuModel menu, {int quantity = 1}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

      if (userId.isEmpty) {
        _snackbar.showErrorSnackbar('Please login first');
        return;
      }

      // Check if menu is available
      if (!menu.isAvailable) {
        _snackbar.showWarningSnackbar('${menu.name} is not available');
        return;
      }

      // Check if item already exists in cart
      final existingIndex = cartItems.indexWhere(
        (item) => item.menuId == menu.id,
      );

      if (existingIndex != -1) {
        // Update quantity if item exists
        final existingItem = cartItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        // Check stock availability
        if (newQuantity > menu.stock) {
          _snackbar.showWarningSnackbar(
            'Insufficient stock! Only ${menu.stock} items available',
          );
          return;
        }

        await updateQuantity(
          existingItem.id,
          newQuantity,
          maxStock: menu.stock,
        );
      } else {
        // Check stock availability for new item
        if (quantity > menu.stock) {
          _snackbar.showWarningSnackbar(
            'Insufficient stock! Only ${menu.stock} items available',
          );
          return;
        }

        if (menu.stock <= 0) {
          _snackbar.showWarningSnackbar('Out of stock!');
          return;
        }

        // Add new item to cart
        final newItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuId: menu.id,
          productName: menu.name,
          price: menu.price,
          quantity: quantity,
          stock: menu.stock, // Add stock from menu
          imageUrl: menu.imageUrl,
          category: menu.category?.name,
        );

        cartItems.add(newItem);

        // Persist to backend (if implemented)
        await _repository.addToCart(
          userId: userId,
          menuId: menu.id,
          productName: menu.name,
          price: menu.price,
          quantity: quantity,
          imageUrl: menu.imageUrl,
          category: menu.category?.name,
        );
      }

      _snackbar.showSuccessSnackbar('${menu.name} added to cart');
      log('✅ Added to cart: ${menu.name} x$quantity');
    } catch (e) {
      log('❌ Error adding to cart: $e');
      _snackbar.showErrorSnackbar('Failed to add to cart');
    }
  }

  Future<void> updateQuantity(
    String itemId,
    int newQuantity, {
    int? maxStock,
  }) async {
    try {
      if (newQuantity <= 0) {
        await removeItem(itemId);
        return;
      }

      // Validate stock if maxStock is provided
      if (maxStock != null && newQuantity > maxStock) {
        _snackbar.showWarningSnackbar(
          'Insufficient stock! Maximum $maxStock items',
        );
        return;
      }

      final index = cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final updatedItem = cartItems[index].copyWith(quantity: newQuantity);
        cartItems[index] = updatedItem;

        await _repository.updateCartItem(
          cartItemId: itemId,
          quantity: newQuantity,
        );

        log('✅ Updated cart item quantity: $newQuantity');
      }
    } catch (e) {
      log('❌ Error updating quantity: $e');
      _snackbar.showErrorSnackbar('Failed to update quantity');
    }
  }

  Future<void> increaseQuantity(CartItemModel item, {int? maxStock}) async {
    await updateQuantity(item.id, item.quantity + 1, maxStock: maxStock);
  }

  Future<void> decreaseQuantity(CartItemModel item) async {
    if (item.quantity > 1) {
      await updateQuantity(item.id, item.quantity - 1);
    } else {
      await removeItem(item.id);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      cartItems.removeWhere((item) => item.id == itemId);
      await _repository.removeFromCart(itemId);
      _snackbar.showSuccessSnackbar('Item removed from cart');
      log('✅ Removed item from cart: $itemId');
    } catch (e) {
      log('❌ Error removing item: $e');
      _snackbar.showErrorSnackbar('Failed to remove item');
    }
  }

  Future<void> clearCart() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

      if (userId.isEmpty) return;

      cartItems.clear();
      selectedDiscount.value = null;
      orderNote.value = '';

      await _repository.clearCart(userId);
      _snackbar.showSuccessSnackbar('Cart cleared');
      log('✅ Cart cleared');
    } catch (e) {
      log('❌ Error clearing cart: $e');
      _snackbar.showErrorSnackbar('Failed to clear cart');
    }
  }

  void setOrderNote(String note) {
    orderNote.value = note;
  }

  void setDiscount(DiscountModel? discount) {
    selectedDiscount.value = discount;
    log('✅ Discount set: ${discount?.name ?? "None"}');
  }

  void clearDiscount() {
    selectedDiscount.value = null;
  }
}
