import 'dart:async';
import 'dart:convert';
import 'package:chiroku_cafe/shared/models/cart_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _cartKey = 'shopping_cart';

  String? get _userId => _supabase.auth.currentUser?.id;

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
      print('Error fetching cart items: \$e');
      return <CartItemModel>[];
    }
  }

  Future<void> _saveCart(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(
        items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: \$e');
      rethrow;
    }
  }

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
      
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex != -1) {
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity + quantity,
        );
      } else {
        cartItems.add(
          CartItemModel(
            id: 'cart_\${DateTime.now().millisecondsSinceEpoch}',
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
      print('Error adding to cart: \$e');
      rethrow;
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final cartItems = await getCartItems();
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      
      if (index != -1) {
        cartItems[index] = cartItems[index].copyWith(quantity: quantity);
        await _saveCart(cartItems);
      }
    } catch (e) {
      print('Error updating quantity: \$e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final cartItems = await getCartItems();
      cartItems.removeWhere((item) => item.id == cartItemId);
      await _saveCart(cartItems);
    } catch (e) {
      print('Error removing from cart: \$e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Error clearing cart: \$e');
      rethrow;
    }
  }

  Future<int> getCartCount() async {
    try {
      final items = await getCartItems();
      return items.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      print('Error getting cart count: \$e');
      return 0;
    }
  }

  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      return items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
    } catch (e) {
      print('Error calculating cart total: \$e');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getCartData() async {
    final items = await getCartItems();
    return items.map((item) => {
      'product_id': item.productId,
      'product_name': item.productName,
      'price': item.price,
      'quantity': item.quantity,
      'category': item.category,
      'image_url': item.imageUrl,
    }).toList();
  }
}
