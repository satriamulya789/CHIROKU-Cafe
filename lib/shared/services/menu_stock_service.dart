import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuStockService {
  final _supabase = Supabase.instance.client;

  /// Check menu stock availability
  Future<Map<String, dynamic>> checkMenuStock(int menuId) async {
    try {
      final response = await _supabase
          .from('menu')
          .select('id, name, stock, is_available')
          .eq('id', menuId)
          .single();

      return response;
    } catch (e) {
      log('❌ Error checking menu stock: $e');
      rethrow;
    }
  }

  /// Check if menu has sufficient stock
  Future<bool> hasEnoughStock(int menuId, int requestedQty) async {
    try {
      final menu = await checkMenuStock(menuId);
      final currentStock = menu['stock'] as int;

      return currentStock >= requestedQty;
    } catch (e) {
      log('❌ Error checking stock availability: $e');
      return false;
    }
  }

  /// Get low stock menus (stock <= 5)
  Future<List<Map<String, dynamic>>> getLowStockMenus() async {
    try {
      final response = await _supabase
          .from('menu')
          .select('id, name, stock, is_available')
          .lte('stock', 5)
          .order('stock', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('❌ Error fetching low stock menus: $e');
      rethrow;
    }
  }

  /// Get out of stock menus
  Future<List<Map<String, dynamic>>> getOutOfStockMenus() async {
    try {
      final response = await _supabase
          .from('menu')
          .select('id, name, stock, is_available')
          .eq('stock', 0)
          .eq('is_available', false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('❌ Error fetching out of stock menus: $e');
      rethrow;
    }
  }

  /// Update menu stock manually (for admin)
  Future<void> updateMenuStock(int menuId, int newStock) async {
    try {
      await _supabase
          .from('menu')
          .update({
            'stock': newStock,
            'is_available': newStock > 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', menuId);

      log('✅ Menu stock updated: ID=$menuId, Stock=$newStock');
    } catch (e) {
      log('❌ Error updating menu stock: $e');
      rethrow;
    }
  }

  /// Increment menu stock (for restocking)
  Future<void> incrementStock(int menuId, int quantity) async {
    try {
      final menu = await checkMenuStock(menuId);
      final currentStock = menu['stock'] as int;
      final newStock = currentStock + quantity;

      await updateMenuStock(menuId, newStock);
      log('✅ Stock incremented: ID=$menuId, +$quantity = $newStock');
    } catch (e) {
      log('❌ Error incrementing stock: $e');
      rethrow;
    }
  }

  /// Listen to menu stock changes (realtime)
  Stream<List<Map<String, dynamic>>> listenToStockChanges() {
    return _supabase
        .from('menu')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Listen to low stock alerts
  Stream<List<Map<String, dynamic>>> listenToLowStockAlerts() {
    return _supabase
        .from('menu')
        .stream(primaryKey: ['id'])
        .lte('stock', 5)
        .order('stock', ascending: true)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Create notification for low stock
  Future<void> createLowStockNotification({
    required String userId,
    required String menuName,
    required int currentStock,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'Stok Rendah',
        'message':
            'Menu "$menuName" memiliki stok rendah ($currentStock tersisa)',
        'type': 'stock',
        'data': {'menu_name': menuName, 'current_stock': currentStock},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      log('✅ Low stock notification created for: $menuName');
    } catch (e) {
      log('❌ Error creating notification: $e');
    }
  }

  /// Create notification for out of stock
  Future<void> createOutOfStockNotification({
    required String userId,
    required String menuName,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'Stok Habis',
        'message': 'Menu "$menuName" sudah habis dan tidak tersedia',
        'type': 'stock',
        'data': {'menu_name': menuName, 'current_stock': 0},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      log('✅ Out of stock notification created for: $menuName');
    } catch (e) {
      log('❌ Error creating notification: $e');
    }
  }

  /// Get all admin user IDs for notifications
  Future<List<String>> getAdminUserIds() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'admin');

      return List<String>.from(response.map((user) => user['id'] as String));
    } catch (e) {
      log('❌ Error fetching admin users: $e');
      return [];
    }
  }

  /// Notify admins about low stock
  Future<void> notifyAdminsLowStock(String menuName, int currentStock) async {
    try {
      final adminIds = await getAdminUserIds();

      for (final adminId in adminIds) {
        await createLowStockNotification(
          userId: adminId,
          menuName: menuName,
          currentStock: currentStock,
        );
      }

      log('✅ Notified ${adminIds.length} admins about low stock: $menuName');
    } catch (e) {
      log('❌ Error notifying admins: $e');
    }
  }

  /// Notify admins about out of stock
  Future<void> notifyAdminsOutOfStock(String menuName) async {
    try {
      final adminIds = await getAdminUserIds();

      for (final adminId in adminIds) {
        await createOutOfStockNotification(userId: adminId, menuName: menuName);
      }

      log('✅ Notified ${adminIds.length} admins about out of stock: $menuName');
    } catch (e) {
      log('❌ Error notifying admins: $e');
    }
  }
}
