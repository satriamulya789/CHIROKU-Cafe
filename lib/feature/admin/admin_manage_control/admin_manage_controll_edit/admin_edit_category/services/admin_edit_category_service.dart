import 'dart:developer';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/repositories/admin_edit_category_repositories.dart';

class CategoryService {
  final CategoryRepositories _repository;

  CategoryService(this._repository);

  /// Watch categories stream (realtime updates from local DB)
  Stream<List<CategoryModel>> watchCategories() {
    log('[Service] Setting up categories stream');
    return _repository.watchCategories();
  }

  /// Create category (offline-first)
  Future<void> createCategory({required String name}) async {
    log('[Service] Creating category: $name');
    await _repository.createCategory(name: name);
  }

  /// Update category (offline-first)
  Future<void> updateCategory(int id, {required String name}) async {
    log('[Service] Updating category $id: $name');
    await _repository.updateCategory(id, name: name);
  }

  /// Delete category (offline-first)
  Future<void> deleteCategory(int id) async {
    log('[Service] Deleting category: $id');
    await _repository.deleteCategory(id);
  }

  /// Sync pending changes to Supabase
  Future<void> syncPendingChanges() async {
    log('[Service] Syncing pending changes');
    await _repository.syncPendingChanges();
  }

  /// Fetch and sync from Supabase
  Future<void> fetchAndSync() async {
    log('[Service] Fetching and syncing from Supabase');
    await _repository.fetchAndSyncFromSupabase();
  }

  /// Subscribe to realtime changes
  void subscribeToRealtime() {
    log('[Service] Subscribing to realtime changes');
    _repository.subscribeToRealtimeChanges();
  }

  /// Unsubscribe from realtime changes
  void unsubscribeFromRealtime() {
    log('[Service] Unsubscribing from realtime changes');
    _repository.unsubscribeFromRealtimeChanges();
  }

  /// Dispose resources
  void dispose() {
    log('[Service] Disposing service');
    _repository.dispose();
  }
}
