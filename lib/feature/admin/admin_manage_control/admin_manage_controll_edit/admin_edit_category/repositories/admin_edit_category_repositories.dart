import 'dart:async';
import 'dart:developer';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/data_sources/categories_local_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/data_sources/categories_remote_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepositories {
  final CategoriesLocalDataSource _localDataSource;
  final CategoriesRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  RealtimeChannel? _realtimeSubscription;

  CategoryRepositories({
    required CategoriesLocalDataSource localDataSource,
    required CategoriesRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  // ==================== STREAM-BASED DATA ACCESS ====================

  /// Watch categories from local database (realtime updates)
  Stream<List<CategoryModel>> watchCategories() {
    log('[Repository] Setting up category stream from local DB');
    return _localDataSource.watchAllCategories().map((categories) {
      return categories.map((c) => CategoryModel.fromDrift(c)).toList();
    });
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create category (offline-first)
  Future<void> createCategory({required String name}) async {
    final isOnline = await _networkInfo.isConnected;
    log('[Repository] Creating category: $name (online: $isOnline)');

    if (isOnline) {
      try {
        // Create in Supabase first
        final created = await _remoteDataSource.createCategory(
          CategoryModel(name: name),
        );
        log('[Repository] Category created in Supabase: ${created.id}');

        // Save to local with Supabase ID
        await _localDataSource.upsertCategory(
          CategoryLocal(
            id: created.id!,
            name: created.name,
            createdAt: created.createdAt ?? DateTime.now(),
            updatedAt: created.updatedAt ?? DateTime.now(),
            syncedAt: DateTime.now(),
            needsSync: false,
            isDeleted: false,
          ),
        );
      } catch (e) {
        log('[Repository] Failed to create in Supabase, saving offline: $e');
        // Fallback to offline
        await _localDataSource.createCategory(name: name);
      }
    } else {
      // Offline: save to local with sync flag
      log('[Repository] Offline: saving category locally');
      await _localDataSource.createCategory(name: name);
    }
  }

  /// Update category (offline-first)
  Future<void> updateCategory(int id, {required String name}) async {
    final isOnline = await _networkInfo.isConnected;
    log('[Repository] Updating category $id: $name (online: $isOnline)');

    if (isOnline) {
      try {
        // Update in Supabase first
        await _remoteDataSource.updateCategory(id, {'name': name});
        log('[Repository] Category updated in Supabase');

        // Update local and mark as synced
        await _localDataSource.updateCategory(id, name: name);
        await _localDataSource.markCategoryAsSynced(id);
      } catch (e) {
        log('[Repository] Failed to update in Supabase, saving offline: $e');
        // Fallback to offline
        await _localDataSource.updateCategory(id, name: name);
      }
    } else {
      // Offline: update local with sync flag
      log('[Repository] Offline: updating category locally');
      await _localDataSource.updateCategory(id, name: name);
    }
  }

  /// Delete category (offline-first)
  Future<void> deleteCategory(int id) async {
    final isOnline = await _networkInfo.isConnected;
    log('[Repository] Deleting category $id (online: $isOnline)');

    if (isOnline) {
      try {
        // Delete from Supabase first
        await _remoteDataSource.deleteCategory(id);
        log('[Repository] Category deleted from Supabase');

        // Permanently delete from local
        await _localDataSource.permanentlyDeleteCategory(id);
      } catch (e) {
        log('[Repository] Failed to delete from Supabase, marking offline: $e');
        // Fallback to offline soft delete
        await _localDataSource.deleteCategory(id);
      }
    } else {
      // Offline: soft delete with sync flag
      log('[Repository] Offline: soft deleting category locally');
      await _localDataSource.deleteCategory(id);
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Sync pending changes to Supabase
  Future<void> syncPendingChanges() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('[Repository] Cannot sync: offline');
      return;
    }

    log('[Repository] Starting sync of pending categories...');
    final pendingCategories = await _localDataSource.getCategoriesNeedingSync();

    if (pendingCategories.isEmpty) {
      log('[Repository] No categories to sync');
      return;
    }

    log('[Repository] Found ${pendingCategories.length} categories to sync');

    for (final category in pendingCategories) {
      try {
        if (category.isDeleted) {
          // Delete from Supabase
          log('[Repository] Syncing DELETE for category ${category.id}');
          await _remoteDataSource.deleteCategory(category.id);
          await _localDataSource.permanentlyDeleteCategory(category.id);
        } else {
          // Check if category exists in Supabase (has syncedAt)
          if (category.syncedAt != null) {
            // UPDATE existing category
            log('[Repository] Syncing UPDATE for category ${category.id}');
            await _remoteDataSource.updateCategory(category.id, {
              'name': category.name,
            });
            await _localDataSource.markCategoryAsSynced(category.id);
          } else {
            // CREATE new category
            log('[Repository] Syncing CREATE for category ${category.id}');
            final created = await _remoteDataSource.createCategory(
              CategoryModel(name: category.name),
            );
            // Update local with Supabase ID
            await _localDataSource.markCategoryAsSynced(
              category.id,
              newId: created.id,
            );
          }
        }
        log('[Repository] ✅ Category ${category.id} synced successfully');
      } catch (e) {
        log('[Repository] ❌ Failed to sync category ${category.id}: $e');
        // Continue with next category
      }
    }

    log('[Repository] Sync completed');
  }

  /// Fetch all categories from Supabase and update local
  Future<void> fetchAndSyncFromSupabase() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('[Repository] Cannot fetch: offline');
      return;
    }

    try {
      log('[Repository] Fetching categories from Supabase...');
      final categories = await _remoteDataSource.fetchCategories();

      log(
        '[Repository] Fetched ${categories.length} categories, updating local DB',
      );

      // Convert to CategoryLocal and upsert
      final localCategories = categories.map((c) {
        return CategoryLocal(
          id: c.id!,
          name: c.name,
          createdAt: c.createdAt ?? DateTime.now(),
          updatedAt: c.updatedAt ?? DateTime.now(),
          syncedAt: DateTime.now(),
          needsSync: false,
          isDeleted: false,
        );
      }).toList();

      await _localDataSource.upsertCategories(localCategories);
      log('[Repository] ✅ Local DB updated with Supabase data');
    } catch (e) {
      log('[Repository] ❌ Failed to fetch from Supabase: $e');
      rethrow;
    }
  }

  // ==================== REALTIME SUBSCRIPTION ====================

  /// Subscribe to realtime changes from Supabase
  void subscribeToRealtimeChanges() {
    log('[Repository] Setting up realtime subscription for categories');

    _realtimeSubscription = _remoteDataSource.subscribeToCategories((
      categories,
    ) async {
      log(
        '[Repository] Realtime update received: ${categories.length} categories',
      );

      // Convert to CategoryLocal and upsert
      final localCategories = categories.map((c) {
        return CategoryLocal(
          id: c.id!,
          name: c.name,
          createdAt: c.createdAt ?? DateTime.now(),
          updatedAt: c.updatedAt ?? DateTime.now(),
          syncedAt: DateTime.now(),
          needsSync: false,
          isDeleted: false,
        );
      }).toList();

      await _localDataSource.upsertCategories(localCategories);
    });
  }

  /// Unsubscribe from realtime changes
  void unsubscribeFromRealtimeChanges() {
    log('[Repository] Unsubscribing from realtime changes');
    _realtimeSubscription?.unsubscribe();
    _realtimeSubscription = null;
  }

  /// Dispose resources
  void dispose() {
    unsubscribeFromRealtimeChanges();
  }
}
