import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from(ApiConstant.categoriesTable)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await _supabase
          .from(ApiConstant.categoriesTable)
          .insert(category.toJson())
          .select()
          .single();
      
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(ApiConstant.categoriesTable)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _supabase
          .from(ApiConstant.categoriesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}