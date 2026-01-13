import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_cart_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/services/cashier_order_cart_service.dart';

class CartRepository {
  final CartService _cartService = CartService();

  /// Get all cart items and convert to models
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final data = await _cartService.getCartItems();
      return data.map((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get cart items - $e');
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
    } catch (e) {
      throw Exception('Repository: Failed to add to cart - $e');
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      await _cartService.updateQuantity(productId, quantity);
    } catch (e) {
      throw Exception('Repository: Failed to update quantity - $e');
    }
  }

  /// Increase item quantity
  Future<void> increaseQuantity(CartItemModel item) async {
    try {
      await _cartService.updateQuantity(item.id, item.quantity + 1);
    } catch (e) {
      throw Exception('Repository: Failed to increase quantity - $e');
    }
  }

  /// Decrease item quantity
  Future<void> decreaseQuantity(CartItemModel item) async {
    try {
      if (item.quantity > 1) {
        await _cartService.updateQuantity(item.id, item.quantity - 1);
      } else {
        await removeItem(item.id);
      }
    } catch (e) {
      throw Exception('Repository: Failed to decrease quantity - $e');
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String productId) async {
    try {
      await _cartService.removeItem(productId);
    } catch (e) {
      throw Exception('Repository: Failed to remove item - $e');
    }
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
    } catch (e) {
      throw Exception('Repository: Failed to clear cart - $e');
    }
  }

  /// Get total count of items in cart
  Future<int> getCartCount() async {
    try {
      return await _cartService.getCartCount();
    } catch (e) {
      return 0;
    }
  }

  /// Calculate subtotal from cart items
  double calculateSubtotal(List<CartItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Calculate tax (10% of subtotal)
  double calculateTax(double subtotal) {
    return subtotal * 0.10;
  }

  /// Calculate discount
  double calculateDiscount(double subtotal, double discountPercentage) {
    return subtotal * (discountPercentage / 100);
  }

  /// Calculate total with tax and discount
  double calculateTotal({
    required double subtotal,
    required double tax,
    required double discount,
  }) {
    return subtotal + tax - discount;
  }
}