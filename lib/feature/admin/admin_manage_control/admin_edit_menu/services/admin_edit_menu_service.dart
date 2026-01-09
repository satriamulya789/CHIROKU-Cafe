import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_menu/repositories/admin_edit_menu_repositories.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_edit_menu/models/admin_edit_menu_model.dart';

class MenuService {
  final MenuRepositories _repository = MenuRepositories();

  Future<List<MenuModel>> fetchMenus() async {
    return await _repository.getMenus();
  }

  Future<void> createMenu(MenuModel menu) async {
    await _repository.createMenu(menu);
  }

  Future<void> updateMenu(int id, {
    String? name,
    int? categoryId,
    double? price,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    int? stock,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (categoryId != null) data['category_id'] = categoryId;
    if (price != null) data['price'] = price;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (isAvailable != null) data['is_available'] = isAvailable;
    if (stock != null) data['stock'] = stock;

    await _repository.updateMenu(id, data);
  }

  Future<void> deleteMenu(int id) async {
    await _repository.deleteMenu(id);
  }
}