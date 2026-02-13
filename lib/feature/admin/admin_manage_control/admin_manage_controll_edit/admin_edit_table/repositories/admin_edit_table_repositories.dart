import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/data_sources/tables_local_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/data_sources/tables_remote_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/models/admin_edit_table_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:developer';

class TableRepositories {
  final NetworkInfo _networkInfo;
  final TablesLocalDataSource _localDataSource;
  final TablesRemoteDataSource _remoteDataSource;

  RealtimeChannel? _realtimeChannel;
  StreamController<List<TableModel>>? _tablesController;

  TableRepositories({
    NetworkInfo? networkInfo,
    TablesLocalDataSource? localDataSource,
    TablesRemoteDataSource? remoteDataSource,
  }) : _networkInfo = networkInfo ?? NetworkInfoImpl(Connectivity()),
       _localDataSource =
           localDataSource ?? TablesLocalDataSource(AppDatabase()),
       _remoteDataSource =
           remoteDataSource ?? TablesRemoteDataSource(Supabase.instance.client);

  // Stream realtime tables data (offline-first)
  Stream<List<TableModel>> watchTables() {
    log('[Repository] Setting up tables stream (offline-first)');

    // Return stream from local database (always available)
    return _localDataSource.watchAllTables().map((driftTables) {
      return driftTables.map((table) => TableModel.fromDrift(table)).toList();
    });
  }

  // Initialize: Sync from Supabase if online
  Future<void> initialize() async {
    log('[Repository] Initializing tables repository');

    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      log('[Repository] Online - fetching from Supabase');
      await _syncFromSupabase();
      _setupRealtimeSubscription();
    } else {
      log('[Repository] Offline - using local data only');
    }
  }

  // Sync data from Supabase to local
  Future<void> _syncFromSupabase() async {
    try {
      log('[Repository] Syncing tables from Supabase to local');
      final remoteTables = await _remoteDataSource.fetchTables();

      // Convert to Drift models and upsert to local
      final driftTables = remoteTables.map((table) {
        return TablesLocal(
          id: table.id!,
          name: table.tableName,
          capacity: table.capacity,
          status: table.status,
          createdAt: table.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          syncedAt: DateTime.now(),
          needsSync: false,
          isLocalOnly: false,
          pendingOperation: null,
          isDeleted: false,
        );
      }).toList();

      await _localDataSource.upsertTables(driftTables);
      log('[Repository] Synced ${driftTables.length} tables to local');
    } catch (e) {
      log('[Repository] Error syncing from Supabase: $e');
    }
  }

  // Setup realtime subscription
  void _setupRealtimeSubscription() {
    log('[Repository] Setting up realtime subscription');

    _realtimeChannel = _remoteDataSource.subscribeToTables((tables) async {
      log('[Repository] Realtime update received');
      await _syncFromSupabase();
    });
  }

  // CREATE - Offline-first
  Future<void> createTable(TableModel table) async {
    log('[Repository] Creating table: ${table.tableName}');

    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        // Online: Create in Supabase first
        log('[Repository] Online - creating in Supabase');
        final created = await _remoteDataSource.createTable(table);

        // Then save to local
        final driftTable = TablesLocal(
          id: created.id!,
          name: created.tableName,
          capacity: created.capacity,
          status: created.status,
          createdAt: created.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          syncedAt: DateTime.now(),
          needsSync: false,
          isLocalOnly: false,
          pendingOperation: null,
          isDeleted: false,
        );
        await _localDataSource.upsertTable(driftTable);
        log('[Repository] Table created and synced');
      } catch (e) {
        log('[Repository] Failed to create in Supabase, saving offline: $e');
        // Fallback to offline
        await _localDataSource.createTable(
          name: table.tableName,
          capacity: table.capacity,
          status: table.status,
        );
      }
    } else {
      // Offline: Save to local with sync flag
      log('[Repository] Offline - saving to local queue');
      await _localDataSource.createTable(
        name: table.tableName,
        capacity: table.capacity,
        status: table.status,
      );
    }
  }

  // UPDATE - Offline-first
  Future<void> updateTable(
    int id, {
    String? tableName,
    int? capacity,
    String? status,
  }) async {
    log('[Repository] Updating table: $id');

    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        // Online: Update in Supabase first
        log('[Repository] Online - updating in Supabase');
        final data = <String, dynamic>{};
        if (tableName != null) data['table_name'] = tableName;
        if (capacity != null) data['capacity'] = capacity;
        if (status != null) data['status'] = status;

        await _remoteDataSource.updateTable(id, data);

        // Then update local
        await _localDataSource.updateTable(
          id,
          name: tableName,
          capacity: capacity,
          status: status,
        );
        await _localDataSource.markTableAsSynced(id);
        log('[Repository] Table updated and synced');
      } catch (e) {
        log('[Repository] Failed to update in Supabase, saving offline: $e');
        // Fallback to offline
        await _localDataSource.updateTable(
          id,
          name: tableName,
          capacity: capacity,
          status: status,
        );
      }
    } else {
      // Offline: Update local with sync flag
      log('[Repository] Offline - updating local queue');
      await _localDataSource.updateTable(
        id,
        name: tableName,
        capacity: capacity,
        status: status,
      );
    }
  }

  // DELETE - Offline-first
  Future<void> deleteTable(int id) async {
    log('[Repository] Deleting table: $id');

    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        // Online: Delete from Supabase first
        log('[Repository] Online - deleting from Supabase');
        await _remoteDataSource.deleteTable(id);

        // Then delete from local
        await _localDataSource.permanentlyDeleteTable(id);
        log('[Repository] Table deleted and synced');
      } catch (e) {
        log('[Repository] Failed to delete from Supabase, marking offline: $e');
        // Fallback to offline
        await _localDataSource.deleteTable(id);
      }
    } else {
      // Offline: Mark for deletion with sync flag
      log('[Repository] Offline - marking for deletion in queue');
      await _localDataSource.deleteTable(id);
    }
  }

  // Sync pending changes to Supabase
  Future<void> syncPendingChanges() async {
    log('[Repository] Syncing pending changes to Supabase');

    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('[Repository] Offline - cannot sync');
      return;
    }

    try {
      final pendingTables = await _localDataSource.getTablesNeedingSync();
      log('[Repository] Found ${pendingTables.length} tables to sync');

      for (final table in pendingTables) {
        try {
          if (table.pendingOperation == 'CREATE') {
            log('[Repository] Syncing CREATE: ${table.name}');
            final model = TableModel(
              tableName: table.name,
              capacity: table.capacity,
              status: table.status,
            );
            final created = await _remoteDataSource.createTable(model);
            await _localDataSource.markTableAsSynced(
              table.id,
              newId: created.id,
            );
          } else if (table.pendingOperation == 'UPDATE') {
            log('[Repository] Syncing UPDATE: ${table.id}');
            final data = {
              'table_name': table.name,
              'capacity': table.capacity,
              'status': table.status,
            };
            await _remoteDataSource.updateTable(table.id, data);
            await _localDataSource.markTableAsSynced(table.id);
          } else if (table.pendingOperation == 'DELETE') {
            log('[Repository] Syncing DELETE: ${table.id}');
            await _remoteDataSource.deleteTable(table.id);
            await _localDataSource.permanentlyDeleteTable(table.id);
          }
        } catch (e) {
          log('[Repository] Error syncing table ${table.id}: $e');
          // Continue with next table
        }
      }

      log('[Repository] Sync completed');
    } catch (e) {
      log('[Repository] Error during sync: $e');
    }
  }

  // Cleanup
  void dispose() {
    log('[Repository] Disposing repository');
    _realtimeChannel?.unsubscribe();
    _tablesController?.close();
  }
}
