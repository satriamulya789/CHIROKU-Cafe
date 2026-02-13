import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/repositories/admin_edit_table_repositories.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:developer';

class TablesSyncService {
  final NetworkInfo _networkInfo;
  final TableRepositories _repository;

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  TablesSyncService({NetworkInfo? networkInfo, TableRepositories? repository})
    : _networkInfo = networkInfo ?? NetworkInfoImpl(Connectivity()),
      _repository = repository ?? TableRepositories();

  // Start listening to connectivity changes
  void startListening() {
    log('[SyncService] Starting connectivity listener');

    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      isOnline,
    ) {
      log(
        '[SyncService] Connectivity changed: ${isOnline ? "ONLINE" : "OFFLINE"}',
      );

      if (isOnline) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    });

    // Check initial connectivity and sync if online
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await _networkInfo.isConnected;
    log(
      '[SyncService] Initial connectivity: ${isOnline ? "ONLINE" : "OFFLINE"}',
    );

    if (isOnline) {
      _onConnected();
    }
  }

  void _onConnected() {
    log('[SyncService] Device is online - triggering sync');
    _syncStatusController.add(SyncStatus.connecting);

    // Trigger immediate sync
    _performSync();

    // Setup periodic sync every 30 seconds while online
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performSync();
    });
  }

  void _onDisconnected() {
    log('[SyncService] Device is offline - stopping periodic sync');
    _syncTimer?.cancel();
    _syncStatusController.add(SyncStatus.offline);
  }

  Future<void> _performSync() async {
    if (_isSyncing) {
      log('[SyncService] Sync already in progress, skipping');
      return;
    }

    try {
      _isSyncing = true;
      _syncStatusController.add(SyncStatus.syncing);

      log('[SyncService] Starting sync process');
      await _repository.syncPendingChanges();

      log('[SyncService] Sync completed successfully');
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      log('[SyncService] Sync failed: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  // Manual sync trigger
  Future<void> syncNow() async {
    log('[SyncService] Manual sync triggered');

    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('[SyncService] Cannot sync - device is offline');
      _syncStatusController.add(SyncStatus.offline);
      return;
    }

    await _performSync();
  }

  // Stop listening and cleanup
  void dispose() {
    log('[SyncService] Disposing sync service');
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus { idle, connecting, syncing, synced, error, offline }
