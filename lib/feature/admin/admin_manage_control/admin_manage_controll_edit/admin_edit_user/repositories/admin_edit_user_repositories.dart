import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/models/admin_edit_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositories {
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

  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      // Create user in auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Update user profile in users table
      await _supabase.from(ApiConstant.usersTable).upsert({
        'id': authResponse.user!.id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
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
      // Delete from users table
      await _supabase
          .from(ApiConstant.usersTable)
          .delete()
          .eq('id', id);
      
      // Note: Deleting from auth.users requires admin API
      // You might need to use Supabase Admin API for this
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}