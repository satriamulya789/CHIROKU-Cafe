import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      print('🔍 Fetching categories from database...');
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      print('📦 Categories response: $response');
      print('📦 Categories count: ${(response as List).length}');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('❌ Error fetching categories: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMenus() async {
    try {
      print('🔍 Fetching menus from database...');
      final response = await _supabase
          .from('menu')
          .select('*, categories(name)')
          .eq('is_available', true)
          .order('name', ascending: true);

      print('📦 Raw response: $response');
      print('📦 Response type: ${response.runtimeType}');
      print('📦 Response length: ${(response as List).length}');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('❌ Error fetching menus: $e');
      print('Stack trace: $stackTrace');
      rethrow;
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
