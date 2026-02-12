import 'dart:developer';
import 'dart:io';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/repositories/admin_edit_menu_repositories.dart';
import 'package:chiroku_cafe/utils/functions/image_cache_helper.dart';
import 'package:get/get.dart';
import 'dart:async';

class AdminEditMenuSyncService extends GetxService {
  final AppDatabase _database;
  final NetworkInfo _networkInfo;
  final MenuRepositories _repository;

  StreamSubscription? _networkSubscription;
  StreamSubscription? _menuStreamSubscription;
  StreamSubscription? _categoryStreamSubscription;

  final isSyncing = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);

  AdminEditMenuSyncService(
    this._database,
    this._networkInfo,
    this._repository,
  );

  @override
  void onInit() {
    super.onInit();
    log('🔄 AdminEditMenuSyncService initialized');
    _setupNetworkListener();
    _setupRealtimeListeners();
    _performInitialSync();
  }

  @override
  void onClose() {
    _networkSubscription?.cancel();
    _menuStreamSubscription?.cancel();
    _categoryStreamSubscription?.cancel();
    super.onClose();
  }

  void _setupNetworkListener() {
    _networkSubscription = _networkInfo.onConnectivityChanged.listen((isConnected) async {
      if (isConnected) {
        log('🌐 Network connected - syncing menus...');
        await syncPendingChanges();
        await syncFromSupabase();
      } else {
        log('📴 Network disconnected - menu sync paused');
      }
    });
  }

  void _setupRealtimeListeners() {
    log('👂 Setting up realtime listeners for menus...');
    
    // Listen to menu changes from Supabase when online
    _menuStreamSubscription = _repository.watchMenus().listen((menus) async {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        log('📡 Received ${menus.length} menus from Supabase realtime');
        await _syncMenusToLocal(menus);
      }
    });

    // Listen to category changes
    _categoryStreamSubscription = _repository.watchCategories().listen((categories) async {
      final isOnline = await _networkInfo.isConnected;
      if (isOnline) {
        log('📡 Received ${categories.length} categories from Supabase realtime');
        await _syncCategoriesToLocal(categories);
      }
    });
  }

  Future<void> _performInitialSync() async {
    await Future.delayed(const Duration(seconds: 2));
    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      log('🚀 Performing initial menu sync...');
      await syncFromSupabase();
    }
  }

  Future<void> syncFromSupabase() async {
    try {
      final isOnline = await _networkInfo.isConnected;
      if (!isOnline) {
        log('📴 Cannot sync from Supabase - offline');
        return;
      }

      log('📥 Syncing data from Supabase...');

      // Fetch categories first using Raw method
      final categories = await _repository.getCategoriesRaw();
      await _syncCategoriesToLocal(categories);

      // Then fetch menus using Raw method
      final menus = await _repository.getMenusRaw();
      await _syncMenusToLocal(menus);

      lastSyncTime.value = DateTime.now();
      log('✅ Sync from Supabase completed');
    } catch (e) {
      log('❌ Error syncing from Supabase: $e');
    }
  }

  Future<void> _syncCategoriesToLocal(List<Map<String, dynamic>> categories) async {
    try {
      log('💾 Syncing ${categories.length} categories to local...');
      
      for (final category in categories) {
        await _database.upsertCategory(CategoryLocal(
          id: category['id'],
          name: category['name'],
          createdAt: DateTime.parse(category['created_at']),
          updatedAt: DateTime.parse(category['updated_at']),
          syncedAt: DateTime.now(),
          needsSync: false,
          isDeleted: false,
        ));
      }
      
      log('✅ Categories synced to local');
    } catch (e) {
      log('❌ Error syncing categories to local: $e');
    }
  }

  Future<void> _syncMenusToLocal(List<Map<String, dynamic>> menus) async {
    try {
      log('💾 Syncing ${menus.length} menus to local...');
      
      // Collect image URLs for precaching
      final imageUrls = <String>[];
      
      for (final menu in menus) {
        await _database.upsertMenu(MenuLocal(
          id: menu['id'],
          categoryId: menu['category_id'],
          name: menu['name'],
          price: (menu['price'] as num).toDouble(),
          description: menu['description'],
          imageUrl: menu['image_url'],
          localImagePath: null,
          isAvailable: menu['is_available'] ?? true,
          stock: menu['stock'] ?? 0,
          createdAt: DateTime.parse(menu['created_at']),
          updatedAt: DateTime.parse(menu['updated_at']),
          syncedAt: DateTime.now(),
          needsSync: false,
          isDeleted: false,
          isLocalOnly: false,
          pendingOperation: null,
        ));
        
        // Add image URL for precaching
        if (menu['image_url'] != null && menu['image_url'].toString().isNotEmpty) {
          imageUrls.add(menu['image_url']);
        }
      }
      
      log('✅ Menus synced to local');
      
      // Precache menu images in background
      if (imageUrls.isNotEmpty) {
        _precacheMenuImages(imageUrls);
      }
    } catch (e) {
      log('❌ Error syncing menus to local: $e');
    }
  }

  Future<void> _precacheMenuImages(List<String> imageUrls) async {
    log('🖼️ Starting to precache ${imageUrls.length} menu images...');
    try {
      await ImageCacheHelper.precacheMenuImages(imageUrls);
      log('✅ Menu images precaching completed');
    } catch (e) {
      log('⚠️ Error precaching menu images: $e');
    }
  }

  Future<void> syncPendingChanges() async {
    if (isSyncing.value) {
      log('⚠️ Sync already in progress');
      return;
    }

    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      log('📴 Cannot sync - offline');
      return;
    }

    isSyncing.value = true;
    log('🔄 Syncing pending menu changes...');

    try {
      final menusToSync = await _database.getMenusNeedingSync();
      
      if (menusToSync.isEmpty) {
        log('✅ No pending menu changes to sync');
        isSyncing.value = false;
        return;
      }

      log('📤 Found ${menusToSync.length} menus to sync');

      for (final menu in menusToSync) {
        try {
          if (menu.pendingOperation == 'DELETE') {
            await _syncDelete(menu);
          } else if (menu.pendingOperation == 'CREATE') {
            await _syncCreate(menu);
          } else if (menu.pendingOperation == 'UPDATE') {
            await _syncUpdate(menu);
          }
        } catch (e) {
          log('❌ Error syncing menu ${menu.id}: $e');
        }
      }

      lastSyncTime.value = DateTime.now();
      log('✅ Menu sync completed');
    } catch (e) {
      log('❌ Error in syncPendingChanges: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> _syncCreate(MenuLocal menu) async {
    log('➕ Syncing CREATE: ${menu.name}');
    
    try {
      // Upload image if exists locally
      String? imageUrl = menu.imageUrl;
      if (menu.localImagePath != null) {
        final file = File(menu.localImagePath!);
        if (await file.exists()) {
          final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await _repository.uploadImage(file, fileName);
          log('📤 Image uploaded: $imageUrl');
          
          // Precache uploaded image
          await ImageCacheHelper.precacheMenuImage(imageUrl);
        }
      }

      // Create in Supabase
      final newId = await _repository.createMenu(
        categoryId: menu.categoryId,
        name: menu.name,
        price: menu.price,
        description: menu.description,
        stock: menu.stock,
        imageUrl: imageUrl,
        isAvailable: menu.isAvailable,
      );

      // Update local with real ID
      await _database.markMenuAsSynced(menu.id, newId: newId);
      
      log('✅ Menu created in Supabase with ID: $newId');
    } catch (e) {
      log('❌ Failed to sync CREATE: $e');
      rethrow;
    }
  }

  Future<void> _syncUpdate(MenuLocal menu) async {
    log('✏️ Syncing UPDATE: ${menu.name}');
    
    try {
      // Upload new image if changed
      String? imageUrl = menu.imageUrl;
      if (menu.localImagePath != null) {
        final file = File(menu.localImagePath!);
        if (await file.exists()) {
          final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await _repository.uploadImage(file, fileName);
          log('📤 Image uploaded: $imageUrl');
          
          // Clear old cache and precache new image
          if (menu.imageUrl != null) {
            await ImageCacheHelper.clearImageCache(menu.imageUrl!, isMenuImage: true);
          }
          await ImageCacheHelper.precacheMenuImage(imageUrl);
        }
      }

      await _repository.updateMenu(
        menu.id,
        categoryId: menu.categoryId,
        name: menu.name,
        price: menu.price,
        description: menu.description,
        stock: menu.stock,
        imageUrl: imageUrl,
        isAvailable: menu.isAvailable,
      );

      await _database.markMenuAsSynced(menu.id);
      
      log('✅ Menu updated in Supabase');
    } catch (e) {
      log('❌ Failed to sync UPDATE: $e');
      rethrow;
    }
  }

  Future<void> _syncDelete(MenuLocal menu) async {
    log('🗑️ Syncing DELETE: ${menu.name}');
    
    try {
      await _repository.deleteMenu(menu.id);
      
      // Delete image if exists
      if (menu.imageUrl != null && menu.imageUrl!.isNotEmpty) {
        await _repository.deleteImage(menu.imageUrl!);
        // Clear image cache
        await ImageCacheHelper.clearImageCache(menu.imageUrl!, isMenuImage: true);
      }

      await _database.permanentlyDeleteMenu(menu.id);
      
      log('✅ Menu deleted from Supabase');
    } catch (e) {
      if (e.toString().contains('23503')) {
        log('⚠️ Cannot delete menu - has orders. Setting to unavailable.');
        await _repository.toggleMenuAvailability(menu.id, false);
        await _database.markMenuAsSynced(menu.id);
      } else {
        log('❌ Failed to sync DELETE: $e');
        rethrow;
      }
    }
  }

  Future<void> manualSync() async {
    log('🔄 Manual sync triggered');
    await syncPendingChanges();
    await syncFromSupabase();
  }

  // Method for permanent delete from local
  Future<void> permanentlyDeleteMenu(int id) async {
    await _database.permanentlyDeleteMenu(id);
  }
}

// Extension for database
extension MenuDatabaseExtension on AppDatabase {
  Future<void> permanentlyDeleteMenu(int id) async {
    log('🗑️ Permanently deleting menu: $id');
    try {
      await (delete(menuLocalTable)..where((tbl) => tbl.id.equals(id))).go();
      log('✅ Menu permanently deleted');
    } catch (e) {
      log('❌ Error permanently deleting menu: $e');
      rethrow;
    }
  }
}