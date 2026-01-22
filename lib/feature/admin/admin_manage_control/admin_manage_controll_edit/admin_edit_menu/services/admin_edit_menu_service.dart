import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/repositories/admin_edit_menu_repositories.dart';

class MenuService {
  final MenuRepositories _repository = MenuRepositories();

  Future<List<MenuModel>> fetchMenus() async {
    return await _repository.getMenus();
  }

  Future<List<CategoryModel>> fetchCategories() async {
    return await _repository.getCategories();
  }

  Future<String> uploadImage(File imageFile, String fileName) async {
    return await _repository.uploadImage(imageFile, fileName);
  }

  Future<void> deleteImage(String imageUrl) async {
    return await _repository.deleteImage(imageUrl);
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
    await _repository.createMenu(
      categoryId: categoryId,
      name: name,
      price: price,
      description: description,
      stock: stock,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    );
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
  }

  Future<void> deleteMenu(int id) async {
    await _repository.deleteMenu(id);
  }

  Future<void> toggleMenuAvailability(int id, bool isAvailable) async {
    await _repository.toggleMenuAvailability(id, isAvailable);
  }
}
