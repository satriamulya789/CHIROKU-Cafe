import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await _supabase
          .from(ApiConstant.menuTable)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load menus: $e');
    }
  }

  Future<MenuModel> createMenu(MenuModel menu) async {
    try {
      final response = await _supabase
          .from(ApiConstant.menuTable)
          .insert(menu.toJson())
          .select()
          .single();
      
      return MenuModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create menu: $e');
    }
  }

  Future<void> updateMenu(int id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(ApiConstant.menuTable)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update menu: $e');
    }
  }

  Future<void> deleteMenu(int id) async {
    try {
      await _supabase
          .from(ApiConstant.menuTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete menu: $e');
    }
  }
}