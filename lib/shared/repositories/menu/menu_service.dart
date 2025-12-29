import 'package:chiroku_cafe/shared/models/menu_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final supabase = Supabase.instance.client;

  /// Get all menus with optional filters
  Future<List<MenuModel>> getMenus({
    String? category,
    bool? isAvailable,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = supabase.from('menu').select('*, categories!inner(name)');

      if (category != null && category.isNotEmpty) {
        query = query.eq('categories.name', category);
      }

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query
          .order('name')
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        return MenuModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch menus: $e');
    }
  }

  /// Search menus by name
  Future<List<MenuModel>> searchMenus(String query) async {
    try {
      final response = await supabase
          .from('menu')
          .select('*, categories!inner(name)')
          .ilike('name', '%$query%')
          .order('name')
          .limit(50);

      return (response as List).map((json) {
        return MenuModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search menus: $e');
    }
  }

  /// Get menu by ID
  Future<MenuModel?> getMenuById(int id) async {
    try {
      final response = await supabase
          .from('menu')
          .select('*, categories!inner(name)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return MenuModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  /// Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');

      return (response as List).map((json) {
        return json as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get menu count
  Future<int> getMenuCount({String? category, bool? isAvailable}) async {
    try {
      var query = supabase.from('menu').select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category_name', category);
      }

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get menu count: $e');
    }
  }

  /// Watch menus for realtime updates
  Stream<List<MenuModel>> watchMenus() {
    return supabase.from('menu').stream(primaryKey: ['id']).order('name').map((
      data,
    ) {
      return data.map((json) {
        return MenuModel.fromJson(json);
      }).toList();
    });
  }

  /// Create new menu
  Future<MenuModel> createMenu(MenuModel menu) async {
    try {
      final response = await supabase
          .from('menu')
          .insert(menu.toInsertJson())
          .select('*, categories!inner(name)')
          .single();

      return MenuModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create menu: $e');
    }
  }

  /// Update menu
  Future<void> updateMenu(MenuModel menu) async {
    try {
      await supabase.from('menu').update(menu.toUpdateJson()).eq('id', menu.id);
    } catch (e) {
      throw Exception('Failed to update menu: $e');
    }
  }

  /// Delete menu
  Future<void> deleteMenu(int menuId) async {
    try {
      await supabase.from('menu').delete().eq('id', menuId);
    } catch (e) {
      throw Exception('Failed to delete menu: $e');
    }
  }

  /// Toggle menu availability
  Future<void> toggleAvailability(int menuId, bool isAvailable) async {
    try {
      await supabase
          .from('menu')
          .update({'is_available': isAvailable})
          .eq('id', menuId);
    } catch (e) {
      throw Exception('Failed to toggle menu availability: $e');
    }
  }
}
