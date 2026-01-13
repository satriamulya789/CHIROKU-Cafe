import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';

  /// Get all cart items from local storage
  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null) return [];

      final List<dynamic> decoded = json.decode(cartJson);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  /// Add item to cart or update quantity if exists
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    String? category,
    String? imageUrl,
    int quantity = 1,
  }) async {
    try {
      final items = await getCartItems();
      
      final existingIndex = items.indexWhere((item) => item['id'] == productId);

      if (existingIndex >= 0) {
        // Update quantity if item exists
        items[existingIndex]['quantity'] = 
            (items[existingIndex]['quantity'] as int) + quantity;
      } else {
        // Add new item
        items.add({
          'id': productId,
          'productName': productName,
          'price': price,
          'quantity': quantity,
          'category': category,
          'imageUrl': imageUrl,
          'note': null,
        });
      }

      await _saveCart(items);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final items = await getCartItems();
      final index = items.indexWhere((item) => item['id'] == productId);

      if (index >= 0) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index]['quantity'] = quantity;
        }
        await _saveCart(items);
      }
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String productId) async {
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item['id'] == productId);
      await _saveCart(items);
    } catch (e) {
      throw Exception('Failed to remove item: $e');
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  /// Get total count of items in cart
  Future<int> getCartCount() async {
    try {
      final items = await getCartItems();
      return items.fold<int>(
        0, 
        (sum, item) => sum + (item['quantity'] as int),
      );
    } catch (e) {
      return 0;
    }
  }

  /// Get total price of all items in cart
  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      return items.fold<double>(
        0.0,
        (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as int)),
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Private method to save cart to storage
  Future<void> _saveCart(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(items);
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }
}