import 'dart:async';
import 'dart:convert';
import 'package:chiroku_cafe/shared/models/cart_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _cartKey = 'shopping_cart';

  // Get current user ID
  String? get _userId => _supabase.auth.currentUser?.id;

  // ==================== LOCAL STORAGE CART ====================

  /// Get all cart items from local storage
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson == null || cartJson.isEmpty) {
        return <CartItemModel>[];
      }

      final List<dynamic> cartList = json.decode(cartJson);
      return cartList
          .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('❌ Error fetching cart items: $e');
      return <CartItemModel>[];
    }
  }

  /// Save cart items to local storage
  Future<void> _saveCart(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(
        items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('❌ Error saving cart: $e');
      rethrow;
    }
  }

  /// Add item to cart (will increase quantity if product already in cart)
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    String? category,
    String? imageUrl,
    int quantity = 1,
  }) async {
    try {
      final cartItems = await getCartItems();
      
      // Check if product already exists in cart
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex != -1) {
        // Update quantity
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        cartItems.add(
          CartItemModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: _userId ?? '',
            productId: productId,
            productName: productName,
            price: price,
            quantity: quantity,
            category: category,
            imageUrl: imageUrl,
            createdAt: DateTime.now(),
          ),
        );
      }

      await _saveCart(cartItems);
    } catch (e) {
      print('❌ Error adding to cart: $e');
      rethrow;
    }
  }

  /// Update cart item quantity (removes item if quantity <= 0)
  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final cartItems = await getCartItems();
      
      if (quantity <= 0) {
        // Remove item
        cartItems.removeWhere((item) => item.id.toString() == cartItemId);
      } else {
        // Update quantity
        final index = cartItems.indexWhere((item) => item.id.toString() == cartItemId);
        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(quantity: quantity);
        }
      }

      await _saveCart(cartItems);
    } catch (e) {
      print('❌ Error updating quantity: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final cartItems = await getCartItems();
      cartItems.removeWhere((item) => item.id.toString() == cartItemId);
      await _saveCart(cartItems);
      print('✅ Item removed from cart');
    } catch (e) {
      print('❌ Error removing from cart: $e');
      rethrow;
    }
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      print('✅ Cart cleared');
    } catch (e) {
      print('❌ Error clearing cart: $e');
      rethrow;
    }
  }

  /// Get cart item count (sum of quantities)
  Future<int> getCartCount() async {
    try {
      final items = await getCartItems();
      return items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      print('❌ Error getting cart count: $e');
      return 0;
    }
  }

  /// Get cart total (sum price * quantity)
  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      return items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
    } catch (e) {
      print('❌ Error calculating cart total: $e');
      return 0.0;
    }
  }
}
