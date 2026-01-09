import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEditUserRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _supabase
          .from(ApiConstant.usersTable)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _supabase
          .from(ApiConstant.usersTable)
          .select()
          .eq('id', id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(ApiConstant.usersTable)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _supabase
          .from(ApiConstant.usersTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}