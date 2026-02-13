import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'dart:developer';

class TablesLocalDataSource {
  final AppDatabase _database;

  TablesLocalDataSource(this._database);

  // CRUD Operations
  Future<int> createTable({
    required String name,
    int capacity = 1,
    String status = 'available',
  }) async {
    log('[LocalDataSource] Creating table offline: $name');
    return await _database.createTableOffline(
      name: name,
      capacity: capacity,
      status: status,
    );
  }

  Future<void> updateTable(
    int id, {
    String? name,
    int? capacity,
    String? status,
  }) async {
    log('[LocalDataSource] Updating table offline: $id');
    await _database.updateTableOffline(
      id,
      name: name,
      capacity: capacity,
      status: status,
    );
  }

  Future<void> deleteTable(int id) async {
    log('[LocalDataSource] Deleting table offline: $id');
    await _database.deleteTableOffline(id);
  }

  Future<List<TablesLocal>> getAllTables() async {
    log('[LocalDataSource] Getting all tables from local DB');
    return await _database.getAllTables();
  }

  Stream<List<TablesLocal>> watchAllTables() {
    log('[LocalDataSource] Setting up realtime watcher for tables');
    return _database.watchAllTables();
  }

  Future<TablesLocal?> getTableById(int id) async {
    log('[LocalDataSource] Getting table by ID: $id');
    return await _database.getTableById(id);
  }

  // Sync Queue Management
  Future<List<TablesLocal>> getTablesNeedingSync() async {
    log('[LocalDataSource] Getting tables needing sync');
    return await _database.getTablesNeedingSync();
  }

  Future<void> markTableAsSynced(int localId, {int? newId}) async {
    log('[LocalDataSource] Marking table as synced: $localId -> $newId');
    await _database.markTableAsSynced(localId, newId: newId);
  }

  // Supabase Sync Operations
  Future<void> upsertTable(TablesLocal table) async {
    log('[LocalDataSource] Upserting table from Supabase: ${table.id}');
    await _database.upsertTable(table);
  }

  Future<void> upsertTables(List<TablesLocal> tables) async {
    log('[LocalDataSource] Bulk upserting ${tables.length} tables');
    await _database.upsertTables(tables);
  }

  Future<void> permanentlyDeleteTable(int id) async {
    log('[LocalDataSource] Permanently deleting table: $id');
    await _database.permanentlyDeleteTable(id);
  }
}
