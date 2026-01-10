import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/repositories/admin_edit_category_repositories.dart';

class CategoryService {
  final CategoryRepositories _repository = CategoryRepositories();

  Future<List<CategoryModel>> fetchCategories() async {
    return await _repository.getCategories();
  }

  Future<void> createCategory(String name) async {
    final category = CategoryModel(name: name);
    await _repository.createCategory(category);
  }

  Future<void> updateCategory(int id, String name) async {
    await _repository.updateCategory(id, {'name': name});
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
  }
}