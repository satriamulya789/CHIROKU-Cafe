import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class AdminEditCategoryController extends GetxController {
  final CategoryService _service;
  final snackbar = CustomSnackbar();

  // Stream-based categories (realtime from local DB)
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;

  // Form controller
  final nameController = TextEditingController();

  AdminEditCategoryController(this._service);

  @override
  void onInit() {
    super.onInit();
    _initCategoriesStream();
    _initialSync();
  }

  @override
  void onClose() {
    _categoriesSubscription?.cancel();
    nameController.dispose();
    super.onClose();
  }

  void _initCategoriesStream() {
    log('👂 Initializing categories realtime stream...');
    _categoriesSubscription = _service.watchCategories().listen(
      (categoriesList) {
        log('📡 Categories stream updated: ${categoriesList.length} items');
        categories.value = categoriesList;
      },
      onError: (error) {
        log('❌ Categories stream error: $error');
        snackbar.showErrorSnackbar('Stream error: $error');
      },
    );
  }

  Future<void> _initialSync() async {
    try {
      isLoading.value = true;
      await _service.fetchAndSync();
      log('✅ Initial category sync completed');
    } catch (e) {
      log('⚠️ Initial sync failed (may be offline): $e');
      // Don't show error - offline is acceptable
    } finally {
      isLoading.value = false;
    }
  }

  List<CategoryModel> get filteredCategories {
    if (searchQuery.value.isEmpty) return categories;
    return categories.where((category) {
      return category.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
    }).toList();
  }

  Future<void> refreshCategories() async {
    try {
      isLoading.value = true;
      await _service.fetchAndSync();
      snackbar.showSuccessSnackbar('Categories refreshed');
    } catch (e) {
      log('⚠️ Refresh failed: $e');
      snackbar.showInfoSnackbar('Using local data');
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
      await _service.createCategory(name: nameController.text);
      Get.back();
      snackbar.showSuccessSnackbar('Category created successfully');
      clearForm();
    } catch (e) {
      log('❌ Create category error: $e');
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
      await _service.updateCategory(id, name: nameController.text);
      Get.back();
      snackbar.showSuccessSnackbar('Category updated successfully');
      clearForm();
    } catch (e) {
      log('❌ Update category error: $e');
      snackbar.showErrorSnackbar('Failed to update category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteCategory(id);
      snackbar.showSuccessSnackbar('Category deleted successfully');
    } catch (e) {
      final errorMessage = e.toString();
      log('❌ Delete category error: $errorMessage');

      if (errorMessage.contains('23503') ||
          errorMessage.contains('foreign key') ||
          errorMessage.contains('violates')) {
        _showCannotDeleteCategoryDialog();
      } else {
        snackbar.showErrorSnackbar('Failed to delete category');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showCannotDeleteCategoryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cannot Delete Category', style: AppTypography.h5),
        content: Text(
          'This category is still linked to several menu items. You must reassign or delete those menus before this category can be removed.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
            ),
            child: Text(
              'Understood',
              style: AppTypography.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void clearForm() {
    nameController.clear();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
