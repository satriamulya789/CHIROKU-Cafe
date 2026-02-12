import 'dart:io';
import 'dart:developer';
import 'package:chiroku_cafe/core/databases/drift_database.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/repositories/admin_edit_menu_repositories.dart';
import 'package:get/get.dart';

class MenuService {
  final MenuRepositories _repository = MenuRepositories();
  late final AppDatabase _database;
  late final NetworkInfo _networkInfo;

  MenuService() {
    _database = Get.find<AppDatabase>();
    _networkInfo = Get.find<NetworkInfo>();
  }

  Future<List<MenuModel>> fetchMenus() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Fetching menus from Supabase...');
      try {
        final menus = await _repository.getMenus();
        
        // Save to local
        final menusRaw = await _repository.getMenusRaw();
        for (final menuData in menusRaw) {
          await _database.upsertMenu(MenuLocal(
            id: menuData['id'],
            categoryId: menuData['category_id'],
            name: menuData['name'],
            price: (menuData['price'] as num).toDouble(),
            description: menuData['description'],
            imageUrl: menuData['image_url'],
            localImagePath: null,
            isAvailable: menuData['is_available'] ?? true,
            stock: menuData['stock'] ?? 0,
            createdAt: DateTime.parse(menuData['created_at']),
            updatedAt: DateTime.parse(menuData['updated_at']),
            syncedAt: DateTime.now(),
            needsSync: false,
            isDeleted: false,
            isLocalOnly: false,
            pendingOperation: null,
          ));
        }
        
        return menus;
      } catch (e) {
        log('❌ Error fetching from Supabase, falling back to local: $e');
        return await _fetchMenusFromLocal();
      }
    } else {
      log('📴 Offline - fetching menus from local database');
      return await _fetchMenusFromLocal();
    }
  }

  Future<List<MenuModel>> _fetchMenusFromLocal() async {
    final localMenus = await _database.getAllMenus();
    final localCategories = await _database.getAllCategories();
    
    return localMenus.map((menu) {
      final category = localCategories.firstWhereOrNull(
        (cat) => cat.id == menu.categoryId,
      );
      
      return MenuModel(
        id: menu.id,
        categoryId: menu.categoryId,
        name: menu.name,
        price: menu.price,
        description: menu.description,
        imageUrl: menu.imageUrl ?? menu.localImagePath,
        isAvailable: menu.isAvailable,
        stock: menu.stock,
        createdAt: menu.createdAt,
        updatedAt: menu.updatedAt,
        category: category != null
            ? CategoryMenuModel(
                id: category.id,
                name: category.name,
              )
            : null,
      );
    }).toList();
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Fetching categories from Supabase...');
      try {
        final categories = await _repository.getCategories();
        
        // Save to local
        final categoriesRaw = await _repository.getCategoriesRaw();
        for (final categoryData in categoriesRaw) {
          await _database.upsertCategory(CategoryLocal(
            id: categoryData['id'],
            name: categoryData['name'],
            createdAt: DateTime.parse(categoryData['created_at']),
            updatedAt: DateTime.parse(categoryData['updated_at']),
            syncedAt: DateTime.now(),
            needsSync: false,
            isDeleted: false,
          ));
        }
        
        return categories;
      } catch (e) {
        log('❌ Error fetching from Supabase, falling back to local: $e');
        return await _fetchCategoriesFromLocal();
      }
    } else {
      log('📴 Offline - fetching categories from local database');
      return await _fetchCategoriesFromLocal();
    }
  }

  Future<List<CategoryModel>> _fetchCategoriesFromLocal() async {
    final localCategories = await _database.getAllCategories();
    return localCategories.map((category) => CategoryModel(
      id: category.id,
      name: category.name,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    )).toList();
  }

  Future<String> uploadImage(File imageFile, String fileName) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Uploading image to Supabase...');
      try {
        return await _repository.uploadImage(imageFile, fileName);
      } catch (e) {
        log('❌ Error uploading image, storing locally: $e');
        return imageFile.path;
      }
    } else {
      log('📴 Offline - storing image locally');
      return imageFile.path;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      try {
        await _repository.deleteImage(imageUrl);
      } catch (e) {
        log('⚠️ Error deleting image: $e');
      }
    }
  }

  Future<void> createMenu({
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Creating menu in Supabase...');
      try {
        await _repository.createMenu(
          categoryId: categoryId,
          name: name,
          price: price,
          description: description,
          stock: stock,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        );
        log('✅ Menu created in Supabase');
      } catch (e) {
        log('❌ Error creating in Supabase, saving offline: $e');
        await _createMenuOffline(
          categoryId: categoryId,
          name: name,
          price: price,
          description: description,
          stock: stock,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        );
      }
    } else {
      log('📴 Offline - creating menu locally');
      await _createMenuOffline(
        categoryId: categoryId,
        name: name,
        price: price,
        description: description,
        stock: stock,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );
    }
  }

  Future<void> _createMenuOffline({
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    await _database.createMenuOffline(
      categoryId: categoryId,
      name: name,
      price: price,
      description: description,
      stock: stock,
      localImagePath: imageUrl,
      isAvailable: isAvailable,
    );
    log('✅ Menu created offline');
  }

  Future<void> updateMenu(
    int id, {
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Updating menu in Supabase...');
      try {
        await _repository.updateMenu(
          id,
          categoryId: categoryId,
          name: name,
          price: price,
          description: description,
          stock: stock,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        );
        log('✅ Menu updated in Supabase');
      } catch (e) {
        log('❌ Error updating in Supabase, saving offline: $e');
        await _updateMenuOffline(
          id,
          categoryId: categoryId,
          name: name,
          price: price,
          description: description,
          stock: stock,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        );
      }
    } else {
      log('📴 Offline - updating menu locally');
      await _updateMenuOffline(
        id,
        categoryId: categoryId,
        name: name,
        price: price,
        description: description,
        stock: stock,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );
    }
  }

  Future<void> _updateMenuOffline(
    int id, {
    required int categoryId,
    required String name,
    required double price,
    String? description,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    await _database.updateMenuOffline(
      id,
      categoryId: categoryId,
      name: name,
      price: price,
      description: description,
      stock: stock,
      localImagePath: imageUrl,
      isAvailable: isAvailable,
    );
    log('✅ Menu updated offline');
  }

  Future<void> deleteMenu(int id) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Deleting menu in Supabase...');
      try {
        await _repository.deleteMenu(id);
        log('✅ Menu deleted in Supabase');
      } catch (e) {
        log('❌ Error deleting in Supabase, marking offline: $e');
        await _database.deleteMenuOffline(id);
      }
    } else {
      log('📴 Offline - marking menu for deletion');
      await _database.deleteMenuOffline(id);
    }
  }

  Future<void> toggleMenuAvailability(int id, bool isAvailable) async {
    final isOnline = await _networkInfo.isConnected;
    
    if (isOnline) {
      log('🌐 Toggling menu availability in Supabase...');
      try {
        await _repository.toggleMenuAvailability(id, isAvailable);
        log('✅ Menu availability updated in Supabase');
      } catch (e) {
        log('❌ Error updating in Supabase, saving offline: $e');
        await _database.updateMenuOffline(id, isAvailable: isAvailable);
      }
    } else {
      log('📴 Offline - updating menu availability locally');
      await _database.updateMenuOffline(id, isAvailable: isAvailable);
    }
  }

  // Stream methods for realtime updates
  Stream<List<MenuModel>> watchMenus() {
    return _database.watchAllMenus().asyncMap((localMenus) async {
      final localCategories = await _database.getAllCategories();
      
      return localMenus.map((menu) {
        final category = localCategories.firstWhereOrNull(
          (cat) => cat.id == menu.categoryId,
        );
        
        return MenuModel(
          id: menu.id,
          categoryId: menu.categoryId,
          name: menu.name,
          price: menu.price,
          description: menu.description,
          imageUrl: menu.imageUrl ?? menu.localImagePath,
          isAvailable: menu.isAvailable,
          stock: menu.stock,
          createdAt: menu.createdAt,
          updatedAt: menu.updatedAt,
          category: category != null
              ? CategoryMenuModel(
                  id: category.id,
                  name: category.name,
                )
              : null,
        );
      }).toList();
    });
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _database.watchAllCategories().map((localCategories) =>
      localCategories.map((category) => CategoryModel(
        id: category.id,
        name: category.name,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      )).toList()
    );
  }
}