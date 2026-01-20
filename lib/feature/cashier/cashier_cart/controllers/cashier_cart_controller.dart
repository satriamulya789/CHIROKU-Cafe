import 'dart:developer';

import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/repositories/cashier_cart_repositories.dart' show CartRepository;
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final CartRepository _repository = CartRepository();
  final CustomSnackbar _snackbar = CustomSnackbar();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString orderNote = ''.obs;
  final RxDouble discountPercentage = 0.0.obs;

  // Computed values
  double get subtotal => _repository.calculateSubtotal(cartItems);
  double get taxAmount => _repository.calculateTax(subtotal);
  double get discountAmount =>
      _repository.calculateDiscount(subtotal, discountPercentage.value);
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

  Future<void> addToCart(MenuModel menu, {int quantity = 1}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      
      if (userId.isEmpty) {
        _snackbar.showErrorSnackbar('Please login first');
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
            'Cannot add more. Only ${menu.stock} items available in stock',
          );
          return;
        }

        await updateQuantity(existingItem.id, newQuantity);
      } else {
        // Check stock availability
        if (quantity > menu.stock) {
          _snackbar.showWarningSnackbar(
            'Cannot add. Only ${menu.stock} items available in stock',
          );
          return;
        }

        // Add new item to cart
        final newItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuId: menu.id,
          productName: menu.name,
          price: menu.price,
          quantity: quantity,
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
      _snackbar.showErrorSnackbar('Failed to add item to cart');
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeItem(itemId);
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

  Future<void> increaseQuantity(CartItemModel item) async {
    await updateQuantity(item.id, item.quantity + 1);
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

  void setDiscount(double percentage) {
    discountPercentage.value = percentage;
  }
}