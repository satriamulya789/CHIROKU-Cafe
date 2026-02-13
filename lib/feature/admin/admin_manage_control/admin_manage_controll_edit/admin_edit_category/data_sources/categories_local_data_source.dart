import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'dart:developer';

class CategoriesLocalDataSource {
  final AppDatabase _database;

  CategoriesLocalDataSource(this._database);

  // CRUD Operations
  Future<int> createCategory({required String name}) async {
    log('[LocalDataSource] Creating category offline: $name');
    return await _database.createCategoryOffline(name: name);
  }

  Future<void> updateCategory(int id, {required String name}) async {
    log('[LocalDataSource] Updating category offline: $id');
    await _database.updateCategoryOffline(id, name: name);
  }

  Future<void> deleteCategory(int id) async {
    log('[LocalDataSource] Deleting category offline: $id');
    await _database.deleteCategoryOffline(id);
  }

  Future<List<CategoryLocal>> getAllCategories() async {
    log('[LocalDataSource] Getting all categories from local DB');
    return await _database.getAllCategories();
  }

  Stream<List<CategoryLocal>> watchAllCategories() {
    log('[LocalDataSource] Setting up realtime watcher for categories');
    return _database.watchAllCategories();
  }

  Future<CategoryLocal?> getCategoryById(int id) async {
    log('[LocalDataSource] Getting category by ID: $id');
    return await _database.getCategoryById(id);
  }

  // Sync Queue Management
  Future<List<CategoryLocal>> getCategoriesNeedingSync() async {
    log('[LocalDataSource] Getting categories needing sync');
    return await _database.getCategoriesNeedingSync();
  }

  Future<void> markCategoryAsSynced(int localId, {int? newId}) async {
    log('[LocalDataSource] Marking category as synced: $localId -> $newId');
    await _database.markCategoryAsSynced(localId, newId: newId);
  }

  // Supabase Sync Operations
  Future<void> upsertCategory(CategoryLocal category) async {
    log('[LocalDataSource] Upserting category from Supabase: ${category.id}');
    await _database.upsertCategory(category);
  }

  Future<void> upsertCategories(List<CategoryLocal> categories) async {
    log('[LocalDataSource] Bulk upserting ${categories.length} categories');
    await _database.upsertCategories(categories);
  }

  Future<void> permanentlyDeleteCategory(int id) async {
    log('[LocalDataSource] Permanently deleting category: $id');
    await _database.permanentlyDeleteCategory(id);
  }
}
