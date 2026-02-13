import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_sync_service.dart';
import 'dart:developer';

class CategoryService {
  final AppDatabase _database;
  final NetworkInfo _networkInfo;
  final CategorySyncService _syncService;

  CategoryService(this._database, this._networkInfo, this._syncService);

  // STREAM FOR REALTIME DATA
  Stream<List<CategoryLocal>> watchCategories() {
    log('👂 Setting up category stream watcher');
    return _database.watchAllCategories();
  }

  // CREATE
  Future<void> createCategory(String name) async {
    log('➕ Creating category: $name');

    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        // Online: Create in local DB first, then sync
        await _database.createCategoryOffline(name: name);
        log('✅ Category created in local DB, triggering sync...');
        await _syncService.syncCategories();
      } else {
        // Offline: Create in local DB only
        await _database.createCategoryOffline(name: name);
        log('📴 Category created offline, will sync when online');
      }
    } catch (e) {
      log('❌ Error creating category: $e');
      rethrow;
    }
  }

  // UPDATE
  Future<void> updateCategory(int id, String name) async {
    log('✏️ Updating category: $id');

    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        // Online: Update in local DB first, then sync
        await _database.updateCategoryOffline(id, name: name);
        log('✅ Category updated in local DB, triggering sync...');
        await _syncService.syncCategories();
      } else {
        // Offline: Update in local DB only
        await _database.updateCategoryOffline(id, name: name);
        log('📴 Category updated offline, will sync when online');
      }
    } catch (e) {
      log('❌ Error updating category: $e');
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteCategory(int id) async {
    log('🗑️ Deleting category: $id');

    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        // Online: Mark as deleted in local DB, then sync
        await _database.deleteCategoryOffline(id);
        log('✅ Category marked for deletion, triggering sync...');
        await _syncService.syncCategories();
      } else {
        // Offline: Mark as deleted in local DB only
        await _database.deleteCategoryOffline(id);
        log('📴 Category marked for deletion offline, will sync when online');
      }
    } catch (e) {
      log('❌ Error deleting category: $e');
      rethrow;
    }
  }

  // FETCH/REFRESH FROM SUPABASE
  Future<void> fetchAndSyncCategories() async {
    log('🔄 Fetching and syncing categories...');

    try {
      final isOnline = await _networkInfo.isConnected;

      if (isOnline) {
        await _syncService.syncCategories();
        log('✅ Categories synced successfully');
      } else {
        log('📴 Device offline, using local data');
      }
    } catch (e) {
      log('❌ Error syncing categories: $e');
      rethrow;
    }
  }

  // GET LOCAL CATEGORIES (for non-stream usage)
  Future<List<CategoryLocal>> getLocalCategories() async {
    log('📖 Getting local categories');
    return await _database.getAllCategories();
  }
}
