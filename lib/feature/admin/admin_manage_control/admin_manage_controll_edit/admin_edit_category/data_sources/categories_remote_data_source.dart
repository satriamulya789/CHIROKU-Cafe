import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class CategoriesRemoteDataSource {
  final SupabaseClient _supabase;

  CategoriesRemoteDataSource(this._supabase);

  // Fetch all categories from Supabase
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      log('[RemoteDataSource] Fetching categories from Supabase');
      final response = await _supabase
          .from(ApiConstant.categoriesTable)
          .select()
          .order('created_at', ascending: false);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      log('[RemoteDataSource] Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      log('[RemoteDataSource] Error fetching categories: $e');
      throw Exception('Failed to fetch categories from Supabase: $e');
    }
  }

  // Create category in Supabase
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      log('[RemoteDataSource] Creating category in Supabase: ${category.name}');
      final response = await _supabase
          .from(ApiConstant.categoriesTable)
          .insert(category.toJson())
          .select()
          .single();

      final created = CategoryModel.fromJson(response);
      log('[RemoteDataSource] Category created with ID: ${created.id}');
      return created;
    } catch (e) {
      log('[RemoteDataSource] Error creating category: $e');
      throw Exception('Failed to create category in Supabase: $e');
    }
  }

  // Update category in Supabase
  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      log('[RemoteDataSource] Updating category in Supabase: $id');
      await _supabase
          .from(ApiConstant.categoriesTable)
          .update(data)
          .eq('id', id);

      log('[RemoteDataSource] Category updated successfully');
    } catch (e) {
      log('[RemoteDataSource] Error updating category: $e');
      throw Exception('Failed to update category in Supabase: $e');
    }
  }

  // Delete category from Supabase
  Future<void> deleteCategory(int id) async {
    try {
      log('[RemoteDataSource] Deleting category from Supabase: $id');
      await _supabase.from(ApiConstant.categoriesTable).delete().eq('id', id);

      log('[RemoteDataSource] Category deleted successfully');
    } catch (e) {
      log('[RemoteDataSource] Error deleting category: $e');
      throw Exception('Failed to delete category from Supabase: $e');
    }
  }

  // Realtime subscription for categories changes
  RealtimeChannel subscribeToCategories(
    void Function(List<CategoryModel>) onData,
  ) {
    log('[RemoteDataSource] Setting up realtime subscription for categories');

    final channel = _supabase
        .channel('categories_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: ApiConstant.categoriesTable,
          callback: (payload) async {
            log(
              '[RemoteDataSource] Realtime event received: ${payload.eventType}',
            );
            // Fetch fresh data after any change
            final categories = await fetchCategories();
            onData(categories);
          },
        )
        .subscribe();

    return channel;
  }
}
