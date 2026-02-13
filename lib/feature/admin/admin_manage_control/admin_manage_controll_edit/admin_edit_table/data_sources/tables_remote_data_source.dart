import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class TablesRemoteDataSource {
  final SupabaseClient _supabase;

  TablesRemoteDataSource(this._supabase);

  // Fetch all tables from Supabase
  Future<List<TableModel>> fetchTables() async {
    try {
      log('[RemoteDataSource] Fetching tables from Supabase');
      final response = await _supabase
          .from(ApiConstant.tablesTable)
          .select()
          .order('created_at', ascending: false);

      final tables = (response as List)
          .map((json) => TableModel.fromJson(json))
          .toList();

      log('[RemoteDataSource] Fetched ${tables.length} tables');
      return tables;
    } catch (e) {
      log('[RemoteDataSource] Error fetching tables: $e');
      throw Exception('Failed to fetch tables from Supabase: $e');
    }
  }

  // Create table in Supabase
  Future<TableModel> createTable(TableModel table) async {
    try {
      log('[RemoteDataSource] Creating table in Supabase: ${table.tableName}');
      final response = await _supabase
          .from(ApiConstant.tablesTable)
          .insert(table.toJson())
          .select()
          .single();

      final created = TableModel.fromJson(response);
      log('[RemoteDataSource] Table created with ID: ${created.id}');
      return created;
    } catch (e) {
      log('[RemoteDataSource] Error creating table: $e');
      throw Exception('Failed to create table in Supabase: $e');
    }
  }

  // Update table in Supabase
  Future<void> updateTable(int id, Map<String, dynamic> data) async {
    try {
      log('[RemoteDataSource] Updating table in Supabase: $id');
      await _supabase.from(ApiConstant.tablesTable).update(data).eq('id', id);

      log('[RemoteDataSource] Table updated successfully');
    } catch (e) {
      log('[RemoteDataSource] Error updating table: $e');
      throw Exception('Failed to update table in Supabase: $e');
    }
  }

  // Delete table from Supabase
  Future<void> deleteTable(int id) async {
    try {
      log('[RemoteDataSource] Deleting table from Supabase: $id');
      await _supabase.from(ApiConstant.tablesTable).delete().eq('id', id);

      log('[RemoteDataSource] Table deleted successfully');
    } catch (e) {
      log('[RemoteDataSource] Error deleting table: $e');
      throw Exception('Failed to delete table from Supabase: $e');
    }
  }

  // Realtime subscription for tables changes
  RealtimeChannel subscribeToTables(void Function(List<TableModel>) onData) {
    log('[RemoteDataSource] Setting up realtime subscription for tables');

    final channel = _supabase
        .channel('tables_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: ApiConstant.tablesTable,
          callback: (payload) async {
            log(
              '[RemoteDataSource] Realtime event received: ${payload.eventType}',
            );
            // Fetch fresh data after any change
            final tables = await fetchTables();
            onData(tables);
          },
        )
        .subscribe();

    return channel;
  }
}
