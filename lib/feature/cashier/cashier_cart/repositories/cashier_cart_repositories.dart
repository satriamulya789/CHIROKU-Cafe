import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/services/cashier_cart_service.dart';

class CartRepository {
  final CartService _cartService = CartService();

  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final data = await _cartService.getCartItems(userId);
      return data.map((e) => CartItemModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get cart items - $e');
    }
  }

  Future<void> addToCart({
    required String userId,
    required int menuId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
    String? category,
    String? note,
  }) async {
    try {
      await _cartService.addToCart(
        userId: userId,
        menuId: menuId,
        productName: productName,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
        category: category,
        note: note,
      );
    } catch (e) {
      throw Exception('Repository: Failed to add to cart - $e');
    }
  }

  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );
    } catch (e) {
      throw Exception('Repository: Failed to update cart item - $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
    } catch (e) {
      throw Exception('Repository: Failed to remove from cart - $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _cartService.clearCart(userId);
    } catch (e) {
      throw Exception('Repository: Failed to clear cart - $e');
    }
  }

  double calculateSubtotal(List<CartItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double calculateTax(double subtotal, {double taxRate = 0.10}) {
    return subtotal * taxRate;
  }

  double calculateDiscount(double subtotal, double discountPercentage) {
    return subtotal * (discountPercentage / 100);
  }

  double calculateTotal({
    required double subtotal,
    required double tax,
    required double discount,
  }) {
    return subtotal + tax - discount;
  }
}