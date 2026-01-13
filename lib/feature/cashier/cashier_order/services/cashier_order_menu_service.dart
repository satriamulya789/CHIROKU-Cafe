import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final _supabase = Supabase.instance.client;

  /// Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get all menus with category information
  Future<List<Map<String, dynamic>>> getMenus() async {
    try {
      final response = await _supabase
          .from('menu')
          .select('*, categories(name)')
          .eq('is_available', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load menus: $e');
    }
  }

  /// Get menus by category
  Future<List<Map<String, dynamic>>> getMenusByCategory(int categoryId) async {
    try {
      final response = await _supabase
          .from('menu')
          .select('*, categories(name)')
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load menus by category: $e');
    }
  }

  /// Search menus
  Future<List<Map<String, dynamic>>> searchMenus(String query) async {
    try {
      final response = await _supabase
          .from('menu')
          .select('*, categories(name)')
          .ilike('name', '%$query%')
          .eq('is_available', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search menus: $e');
    }
  }

  /// Get menu by ID
  Future<Map<String, dynamic>?> getMenuById(int id) async {
    try {
      final response = await _supabase
          .from('menu')
          .select('*, categories(name)')
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load menu: $e');
    }
  }
}

