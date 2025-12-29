import 'package:chiroku_cafe/shared/models/table_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TableService {
  final supabase = Supabase.instance.client;

  /// Get all tables
  Future<List<TableModel>> getTables({String? status}) async {
    try {
      var query = supabase.from('tables').select();

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query.order('table_name');

      if (response is! List) {
        return [];
      }

      return response.map((json) {
        return TableModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tables: $e');
    }
  }

  /// Get table by ID
  Future<TableModel?> getTableById(int id) async {
    try {
      final response = await supabase
          .from('tables')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return TableModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch table: $e');
    }
  }

  /// Get available tables
  Future<List<TableModel>> getAvailableTables() async {
    return getTables(status: 'available');
  }

  /// Get occupied tables
  Future<List<TableModel>> getOccupiedTables() async {
    return getTables(status: 'occupied');
  }

  /// Get reserved tables
  Future<List<TableModel>> getReservedTables() async {
    return getTables(status: 'reserved');
  }

  /// Update table status
  Future<void> updateTableStatus(int tableId, String newStatus) async {
    try {
      await supabase
          .from('tables')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tableId);
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  /// Get table statistics
  Future<Map<String, int>> getTableStats() async {
    try {
      final allTables = await getTables();

      int available = 0;
      int occupied = 0;
      int reserved = 0;

      for (var table in allTables) {
        switch (table.status.toLowerCase()) {
          case 'available':
            available++;
            break;
          case 'occupied':
            occupied++;
            break;
          case 'reserved':
            reserved++;
            break;
        }
      }

      return {
        'total': allTables.length,
        'available': available,
        'occupied': occupied,
        'reserved': reserved,
      };
    } catch (e) {
      throw Exception('Failed to fetch table stats: $e');
    }
  }

  /// Watch tables for realtime updates
  Stream<List<TableModel>> watchTables() {
    return supabase
        .from('tables')
        .stream(primaryKey: ['id'])
        .order('table_name')
        .map((data) {
          if (data is! List) return <TableModel>[];

          return data.map((json) {
            return TableModel.fromJson(json as Map<String, dynamic>);
          }).toList();
        });
  }

  /// Create new table
  Future<TableModel> createTable(TableModel table) async {
    try {
      final response = await supabase
          .from('tables')
          .insert(table.toInsertJson())
          .select()
          .single();

      return TableModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  /// Update table
  Future<void> updateTable(TableModel table) async {
    try {
      await supabase
          .from('tables')
          .update(table.toUpdateJson())
          .eq('id', table.id);
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  /// Delete table
  Future<void> deleteTable(int tableId) async {
    try {
      await supabase.from('tables').delete().eq('id', tableId);
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  /// Mark table as available
  Future<void> markAsAvailable(int tableId) async {
    await updateTableStatus(tableId, 'available');
  }

  /// Mark table as occupied
  Future<void> markAsOccupied(int tableId) async {
    await updateTableStatus(tableId, 'occupied');
  }

  /// Mark table as reserved
  Future<void> markAsReserved(int tableId) async {
    await updateTableStatus(tableId, 'reserved');
  }
}
