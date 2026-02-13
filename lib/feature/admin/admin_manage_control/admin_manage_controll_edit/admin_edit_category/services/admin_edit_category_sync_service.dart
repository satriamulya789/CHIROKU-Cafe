import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/repositories/admin_edit_category_repositories.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class CategorySyncService extends GetxService {
  final AppDatabase _database;
  final NetworkInfo _networkInfo;
  final CategoryRepositories _repository;

  final isSyncing = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);
  StreamSubscription? _connectivitySubscription;

  CategorySyncService(this._database, this._networkInfo, this._repository);

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      log(
        '🌐 Category Sync - Connectivity: ${connected ? "ONLINE" : "OFFLINE"}',
      );

      if (connected) {
        Future.delayed(const Duration(seconds: 2), () async {
          final isStillOnline = await _networkInfo.isConnected;
          if (isStillOnline) {
            syncCategories();
          }
        });
      }
    });
  }

  Future<void> syncCategories() async {
    if (isSyncing.value) {
      log('⚠️ Category sync already in progress');
      return;
    }

    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('⚠️ Cannot sync categories - device is offline');
      return;
    }

    log('🔄 Starting category sync...');
    isSyncing.value = true;

    try {
      // 1. Sync pending local changes to Supabase
      await _syncLocalChangesToSupabase();

      // 2. Fetch latest data from Supabase
      await _fetchAndSaveFromSupabase();

      lastSyncTime.value = DateTime.now();
      log('✅ Category sync completed at ${lastSyncTime.value}');
    } catch (e) {
      log('❌ Category sync failed: $e');
      rethrow;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> _syncLocalChangesToSupabase() async {
    log('📤 Syncing local category changes to Supabase...');

    final pendingCategories = await _database.getCategoriesNeedingSync();
    log('📋 Found ${pendingCategories.length} categories to sync');

    for (final category in pendingCategories) {
      try {
        if (category.isDeleted) {
          // Delete from Supabase
          log('🗑️ Deleting category from Supabase: ${category.id}');
          await _repository.deleteCategory(category.id);
          await _database.permanentlyDeleteCategory(category.id);
          log('✅ Category deleted from Supabase and local DB');
        } else {
          // Create or Update in Supabase
          final categoryData = {
            'name': category.name,
            'updated_at': DateTime.now().toIso8601String(),
          };

          if (category.id > 0 && category.syncedAt != null) {
            // Update existing
            log('✏️ Updating category in Supabase: ${category.id}');
            await _repository.updateCategory(category.id, categoryData);
            await _database.markCategoryAsSynced(category.id);
            log('✅ Category updated in Supabase');
          } else {
            // Create new
            log('➕ Creating new category in Supabase: ${category.name}');
            final newCategory = await _repository.createCategoryWithReturn(
              category.name,
            );

            // Replace local temp ID with Supabase ID
            await _database.markCategoryAsSynced(
              category.id,
              newId: newCategory['id'] as int,
            );
            log('✅ Category created in Supabase with ID: ${newCategory['id']}');
          }
        }
      } catch (e) {
        log('❌ Error syncing category ${category.id}: $e');
        // Continue with next category
      }
    }
  }

  Future<void> _fetchAndSaveFromSupabase() async {
    log('📥 Fetching categories from Supabase...');

    try {
      final categories = await _repository.getCategories();
      log('📦 Fetched ${categories.length} categories from Supabase');

      // Convert to CategoryLocal and save
      final categoriesLocal = categories.map((cat) {
        return CategoryLocal(
          id: cat.id!,
          name: cat.name,
          createdAt: cat.createdAt ?? DateTime.now(),
          updatedAt: cat.updatedAt ?? DateTime.now(),
          syncedAt: DateTime.now(),
          needsSync: false,
          isDeleted: false, 
        );
      }).toList();

      await _database.upsertCategories(categoriesLocal);
      log('✅ Categories saved to local database');
    } catch (e) {
      log('❌ Error fetching categories from Supabase: $e');
      rethrow;
    }
  }

  Future<void> forceSyncCategories() async {
    log('🔄 Force sync categories requested');
    await syncCategories();
  }
}
