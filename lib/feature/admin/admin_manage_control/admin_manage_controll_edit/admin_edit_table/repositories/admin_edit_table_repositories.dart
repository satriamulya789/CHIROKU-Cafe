import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TableRepositories {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<TableModel>> getTables() async {
    try {
      final response = await _supabase
          .from(ApiConstant.tablesTable)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => TableModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  Future<TableModel> createTable(TableModel table) async {
    try {
      final response = await _supabase
          .from(ApiConstant.tablesTable)
          .insert(table.toJson())
          .select()
          .single();
      
      return TableModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  Future<void> updateTable(int id, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from(ApiConstant.tablesTable)
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      await _supabase
          .from(ApiConstant.tablesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }
}