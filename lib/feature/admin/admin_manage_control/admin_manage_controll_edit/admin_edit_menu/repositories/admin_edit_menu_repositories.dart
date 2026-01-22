import 'dart:io';
import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String bucketName = 'menus';

  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await _supabase
          .from(ApiConstant.menuTable)
          .select('*, categories!fk_menu_category(id, name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MenuModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load menus: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from(ApiConstant.categoriesTable)
          .select()
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      // Upload to Supabase Storage
      await _supabase.storage.from(bucketName).upload(fileName, imageFile);

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      await _supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      // Don't throw error if image deletion fails
      print('Warning: Failed to delete image: $e');
    }
  }

  Future<void> createMenu({
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      await _supabase.from(ApiConstant.menuTable).insert({
        'category_id': categoryId,
        'name': name,
        'price': price,
        'description': description,
        'stock': stock,
        'image_url': imageUrl,
        'is_available': isAvailable,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create menu: $e');
    }
  }

  Future<void> updateMenu(
    int id, {
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      await _supabase
          .from(ApiConstant.menuTable)
          .update({
            'category_id': categoryId,
            'name': name,
            'price': price,
            'description': description,
            'stock': stock,
            'image_url': imageUrl,
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update menu: $e');
    }
  }

  Future<void> deleteMenu(int id) async {
    try {
      await _supabase.from(ApiConstant.menuTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete menu: $e');
    }
  }

  Future<void> toggleMenuAvailability(int id, bool isAvailable) async {
    try {
      await _supabase
          .from(ApiConstant.menuTable)
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update menu availability: $e');
    }
  }
}
