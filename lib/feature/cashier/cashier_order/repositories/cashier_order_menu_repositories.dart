import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_category_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/services/cashier_order_menu_service.dart';

class MenuRepository {
  final MenuService _menuService = MenuService();

  Future<List<CategoryMenuModel>> getCategories() async {
    final data = await _menuService.getCategories();
    return data.map((e) => CategoryMenuModel.fromJson(e)).toList();
  }

  Future<List<MenuModel>> getMenus() async {
    final data = await _menuService.getMenus();
    return data.map((e) => MenuModel.fromJson(e)).toList();
  }

  Future<List<MenuModel>> getMenusByCategory(int categoryId) async {
    try {
      final data = await _menuService.getMenusByCategory(categoryId);
      return data.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get menus by category - $e');
    }
  }

  Future<List<MenuModel>> searchMenus(String query) async {
    try {
      final data = await _menuService.searchMenus(query);
      return data.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Repository: Failed to search menus - $e');
    }
  }

  Future<MenuModel?> getMenuById(int id) async {
    try {
      final data = await _menuService.getMenuById(id);
      if (data == null) return null;
      return MenuModel.fromJson(data);
    } catch (e) {
      throw Exception('Repository: Failed to get menu by ID - $e');
    }
  }

  List<MenuModel> filterMenus({
    required List<MenuModel> menus,
    String? searchQuery,
    String? categoryName,
  }) {
    return menus.where((menu) {
      final matchesSearch =
          searchQuery == null ||
          searchQuery.isEmpty ||
          menu.name.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory =
          categoryName == null ||
          categoryName == 'all' ||
          (menu.category?.name == categoryName);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<MenuModel> getAvailableMenus(List<MenuModel> menus) {
    return menus
        .where((menu) => menu.isAvailable == true && (menu.stock > 0))
        .toList();
  }
}
