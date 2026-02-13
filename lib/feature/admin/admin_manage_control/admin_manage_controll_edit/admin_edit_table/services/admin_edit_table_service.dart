import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/repositories/admin_edit_table_repositories.dart';
import 'dart:developer';

class TableService {
  final TableRepositories _repository;

  TableService({TableRepositories? repository})
    : _repository = repository ?? TableRepositories();

  // Initialize repository
  Future<void> initialize() async {
    log('[Service] Initializing table service');
    await _repository.initialize();
  }

  // Stream realtime tables
  Stream<List<TableModel>> watchTables() {
    log('[Service] Watching tables stream');
    return _repository.watchTables();
  }

  // Create table
  Future<void> createTable(String tableName, int capacity) async {
    log('[Service] Creating table: $tableName');
    final table = TableModel(tableName: tableName, capacity: capacity);
    await _repository.createTable(table);
  }

  // Update table
  Future<void> updateTable(
    int id, {
    String? tableName,
    int? capacity,
    String? status,
  }) async {
    log('[Service] Updating table: $id');
    await _repository.updateTable(
      id,
      tableName: tableName,
      capacity: capacity,
      status: status,
    );
  }

  // Delete table
  Future<void> deleteTable(int id) async {
    log('[Service] Deleting table: $id');
    await _repository.deleteTable(id);
  }

  // Sync pending changes
  Future<void> syncPendingChanges() async {
    log('[Service] Triggering sync');
    await _repository.syncPendingChanges();
  }

  // Cleanup
  void dispose() {
    log('[Service] Disposing service');
    _repository.dispose();
  }
}
