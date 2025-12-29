import 'package:chiroku_cafe/shared/models/cart_models.dart';
import 'package:chiroku_cafe/shared/repositories/cart/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  // Observable variables
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble discountPercentage = 0.0.obs;
  final RxString orderNote = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  // ==================== COMPUTED PROPERTIES ====================

  int get itemCount => cartItems.length;

  int get totalQuantity =>
      cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold<double>(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  double get discountAmount => subtotal * (discountPercentage.value / 100);

  double get taxAmount => (subtotal - discountAmount) * 0.1;

  double get total => subtotal - discountAmount + taxAmount;

  double get totalPrice => subtotal;

  // ==================== CART OPERATIONS ====================

  /// Fetch cart items from database
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      final items = await _cartService.getCartItems();
      cartItems.value = items;
    } catch (e) {
      _showErrorSnackbar('Failed to load cart', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    String? category,
    String? imageUrl,
    int quantity = 1,
  }) async {
    try {
      await _cartService.addToCart(
        productId: productId,
        productName: productName,
        price: price,
        category: category,
        imageUrl: imageUrl,
        quantity: quantity,
      );

      _showSuccessSnackbar('$productName added to cart');
    } catch (e) {
      _showErrorSnackbar('Failed to add to cart', e.toString());
    }
  }

  /// Increase quantity
  Future<void> increaseQuantity(CartItemModel item) async {
    try {
      await _cartService.updateQuantity(
        cartItemId: item.id,
        quantity: item.quantity + 1,
      );
      await fetchCartItems(); // Refresh cart to show updated quantity
    } catch (e) {
      _showErrorSnackbar('Failed to update quantity', e.toString());
    }
  }

  /// Decrease quantity
  Future<void> decreaseQuantity(CartItemModel item) async {
    try {
      if (item.quantity > 1) {
        await _cartService.updateQuantity(
          cartItemId: item.id,
          quantity: item.quantity - 1,
        );
        await fetchCartItems(); // Refresh cart to show updated quantity
      } else {
        await removeItem(item.id);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update quantity', e.toString());
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      await fetchCartItems(); // Refresh cart after removing item
      _showSuccessSnackbar('Item removed from cart');
    } catch (e) {
      _showErrorSnackbar('Failed to remove item', e.toString());
    }
  }

  /// Clear all cart
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      await fetchCartItems(); // Refresh cart after clearing
      _showSuccessSnackbar('Cart cleared');
    } catch (e) {
      _showErrorSnackbar('Failed to clear cart', e.toString());
    }
  }

  /// Set discount percentage
  void setDiscount(double percentage) {
    discountPercentage.value = percentage;
  }

  /// Set order note
  void setOrderNote(String note) {
    orderNote.value = note;
  }

  // ==================== SNACKBAR HELPERS ====================

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[700],
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      titleText: Text(
        'Success',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          fontStyle: GoogleFonts.montserrat().fontStyle,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontStyle: GoogleFonts.montserrat().fontStyle,
        ),
      ),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      titleText: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
          fontStyle: GoogleFonts.montserrat().fontStyle,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontStyle: GoogleFonts.montserrat().fontStyle,
        ),
      ),
    );
  }
}
