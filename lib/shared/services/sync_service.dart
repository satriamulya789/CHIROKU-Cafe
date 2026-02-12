import 'dart:async';
import 'dart:developer';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/repositories/admin_edit_user_repositories.dart';
import 'package:get/get.dart';

class SyncService extends GetxService {
  final AppDatabase database;
  final NetworkInfo networkInfo;
  
  Timer? _periodicSyncTimer;
  StreamSubscription? _networkSubscription;

  SyncService({
    required this.database,
    required this.networkInfo,
  });

  @override
  void onInit() {
    super.onInit();
    log('🔄 Initializing Sync Service...');
    
    _setupNetworkListener();
    _setupPeriodicSync();
    _initialSync();
  }

  @override
  void onClose() {
    _periodicSyncTimer?.cancel();
    _networkSubscription?.cancel();
    super.onClose();
  }

  void _setupNetworkListener() {
    _networkSubscription = networkInfo.onConnectivityChanged.listen((isConnected) async {
      if (isConnected) {
        log('🌐 Network connected - triggering sync...');
        await syncAllPendingChanges();
      } else {
        log('📴 Network disconnected - pausing sync');
      }
    });
    log('✅ Network listener setup in SyncService');
  }

  void _setupPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        final isOnline = await networkInfo.isConnected;
        if (isOnline) {
          log('⏰ Periodic sync triggered...');
          await syncAllPendingChanges();
        }
      },
    );
    log('✅ Periodic sync setup (every 5 minutes)');
  }

  Future<void> _initialSync() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final isOnline = await networkInfo.isConnected;
      if (isOnline) {
        log('🚀 Initial sync starting...');
        await syncAllPendingChanges();
      } else {
        log('📴 Skipping initial sync - offline');
      }
    } catch (e) {
      log('❌ Initial sync error: $e');
    }
  }

  Future<void> syncAllPendingChanges() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        log('📴 Cannot sync: offline');
        return;
      }

      log('🔄 Syncing all pending changes...');

      await _syncUsers();

      log('✅ All pending changes synced');
    } catch (e) {
      log('❌ Error syncing pending changes: $e');
    }
  }

  Future<void> _syncUsers() async {
    try {
      log('🔄 Checking users needing sync...');
      final usersNeedingSync = await database.getUsersNeedingSync();
      
      if (usersNeedingSync.isEmpty) {
        log('✅ No users need sync');
        return;
      }

      log('📤 Found ${usersNeedingSync.length} users to sync');

      try {
        final userRepo = Get.find<UserRepositories>();
        await userRepo.syncPendingChanges();
        log('✅ Users synced successfully via UserRepositories');
      } catch (e) {
        log('❌ Error syncing users: $e');
        rethrow;
      }
    } catch (e) {
      log('❌ Error in _syncUsers: $e');
    }
  }

  Future<void> manualSync() async {
    log('🔄 Manual sync triggered by user...');
    await syncAllPendingChanges();
  }
}