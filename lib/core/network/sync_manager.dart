import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class SyncManager extends GetxService {
  final AppDatabase _database;
  final NetworkInfo _networkInfo;

  final isOnline = false.obs;
  final isSyncing = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);

  StreamSubscription? _connectivitySubscription;

  SyncManager(this._database, this._networkInfo);

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
    _checkInitialConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((connected) {
      log('🌐 Connectivity changed: ${connected ? "ONLINE" : "OFFLINE"}');
      isOnline.value = connected;
      
      if (connected) {
        _onConnectivityRestored();
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    isOnline.value = await _networkInfo.isConnected;
    log('🌐 Initial connectivity: ${isOnline.value ? "ONLINE" : "OFFLINE"}');
  }

  void _onConnectivityRestored() {
    log('✅ Connectivity restored - triggering sync');
    // Trigger sync after small delay to ensure stable connection
    Future.delayed(const Duration(seconds: 2), () {
      if (isOnline.value) {
        triggerSync();
      }
    });
  }

  Future<void> triggerSync() async {
    if (isSyncing.value) {
      log('⚠️ Sync already in progress, skipping...');
      return;
    }

    if (!isOnline.value) {
      log('⚠️ Cannot sync - device is offline');
      return;
    }

    log('🔄 Starting sync...');
    isSyncing.value = true;

    try {
      // Notify listeners that sync is starting
      Get.find<SyncManager>().onSyncStart();
      
      // Sync will be handled by AdminEditUserSyncService
      // This is just the trigger point
      
      lastSyncTime.value = DateTime.now();
      log('✅ Sync completed at ${lastSyncTime.value}');
      
      Get.find<SyncManager>().onSyncComplete();
    } catch (e) {
      log('❌ Sync failed: $e');
      Get.find<SyncManager>().onSyncError(e.toString());
    } finally {
      isSyncing.value = false;
    }
  }

  // Callback methods for sync events
  void onSyncStart() {
    log('📡 Sync start callback triggered');
  }

  void onSyncComplete() {
    log('✅ Sync complete callback triggered');
  }

  void onSyncError(String error) {
    log('❌ Sync error callback: $error');
  }

  Future<void> forceSyncUsers() async {
    log('🔄 Force sync users requested');
    await triggerSync();
  }
}