import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditCategoryController extends GetxController {
  final CategoryService _service = CategoryService();

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
      return category.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _service.fetchCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e',
          snackPosition: SnackPosition.BOTTOM);
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
        Get.snackbar('Error', 'Category name is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isLoading.value = true;
      await _service.createCategory(nameController.text);
      await fetchCategories();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Category created successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create category: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(int id) async {
    try {
      if (nameController.text.isEmpty) {
        Get.snackbar('Error', 'Category name is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isLoading.value = true;
      await _service.updateCategory(id, nameController.text);
      await fetchCategories();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Category updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteCategory(id);
      await fetchCategories();
      Get.snackbar('Success', 'Category deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e',
          snackPosition: SnackPosition.BOTTOM);
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