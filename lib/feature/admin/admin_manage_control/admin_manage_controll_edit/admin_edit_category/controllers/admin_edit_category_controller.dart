import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditCategoryController extends GetxController {
  final CategoryService _service = CategoryService();
  final snackbar = CustomSnackbar();

  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Form controller
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  List<CategoryModel> get filteredCategories {
    if (searchQuery.value.isEmpty) return categories;
    return categories.where((category) {
      return category.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
    }).toList();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _service.fetchCategories();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to fetch categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setEditCategory(CategoryModel category) {
    nameController.text = category.name;
  }

  Future<void> createCategory() async {
    try {
      if (nameController.text.isEmpty) {
        snackbar.showErrorSnackbar('Category name is required');
        return;
      }

      isLoading.value = true;
      await _service.createCategory(nameController.text);
      await fetchCategories();
      Get.back();
      snackbar.showSuccessSnackbar('Category created successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to create category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(int id) async {
    try {
      if (nameController.text.isEmpty) {
        snackbar.showErrorSnackbar('Category name is required');
        return;
      }

      isLoading.value = true;
      await _service.updateCategory(id, nameController.text);
      await fetchCategories();
      Get.back();
      snackbar.showSuccessSnackbar('Category updated successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to update category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteCategory(id);
      await fetchCategories();
      snackbar.showSuccessSnackbar('Category deleted successfully');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('23503')) {
        snackbar.showErrorSnackbar(
          'Cannot delete category because it is still used by some menus. Please delete or reassign those menus first.',
        );
      } else {
        snackbar.showErrorSnackbar('Failed to delete category: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    nameController.clear();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
