import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/services/admin_edit_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditMenuController extends GetxController {
  final MenuService _service = MenuService();
  final ImagePicker _picker = ImagePicker();

  final menus = <MenuModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final searchQuery = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final stockController = TextEditingController();
  final selectedCategoryId = Rxn<int>();
  final selectedImageFile = Rxn<File>();
  final imageUrl = RxnString();
  final isAvailable = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
    fetchCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    stockController.dispose();
    super.onClose();
  }

  List<MenuModel> get filteredMenus {
    if (searchQuery.value.isEmpty) return menus;
    return menus.where((menu) {
      return menu.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;
      menus.value = await _service.fetchMenus();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch menus: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      categories.value = await _service.fetchCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void setEditMenu(MenuModel menu) {
    nameController.text = menu.name;
    priceController.text = menu.price.toString();
    descriptionController.text = menu.description ?? '';
    stockController.text = menu.stock.toString();
    selectedCategoryId.value = menu.categoryId;
    imageUrl.value = menu.imageUrl;
    isAvailable.value = menu.isAvailable;
    selectedImageFile.value = null;
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void removeImage() {
    selectedImageFile.value = null;
    imageUrl.value = null;
  }

  Future<String?> _uploadImage() async {
    if (selectedImageFile.value == null) return imageUrl.value;

    try {
      isUploadingImage.value = true;
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadedUrl = await _service.uploadImage(
        selectedImageFile.value!,
        fileName,
      );
      return uploadedUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> createMenu() async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;

      // Upload image first
      String? uploadedImageUrl;
      if (selectedImageFile.value != null) {
        uploadedImageUrl = await _uploadImage();
        if (uploadedImageUrl == null) {
          isLoading.value = false;
          return; // Stop if image upload failed
        }
      }

      await _service.createMenu(
        categoryId: selectedCategoryId.value!,
        name: nameController.text.trim(),
        price: double.parse(priceController.text),
        description: descriptionController.text.trim(),
        stock: int.parse(stockController.text),
        imageUrl: uploadedImageUrl,
        isAvailable: isAvailable.value,
      );

      await fetchMenus();
      clearForm();
      Get.back();
      Get.snackbar(
        'Success',
        'Menu created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create menu: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMenu(int id) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;

      // Upload new image if selected
      String? uploadedImageUrl = imageUrl.value;
      if (selectedImageFile.value != null) {
        uploadedImageUrl = await _uploadImage();
        if (uploadedImageUrl == null) {
          isLoading.value = false;
          return;
        }
      }

      await _service.updateMenu(
        id,
        categoryId: selectedCategoryId.value!,
        name: nameController.text.trim(),
        price: double.parse(priceController.text),
        description: descriptionController.text.trim(),
        stock: int.parse(stockController.text),
        imageUrl: uploadedImageUrl,
        isAvailable: isAvailable.value,
      );

      await fetchMenus();
      clearForm();
      Get.back();
      Get.snackbar(
        'Success',
        'Menu updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update menu: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMenu(int id, String? imageUrl) async {
    try {
      isLoading.value = true;
      
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _service.deleteImage(imageUrl);
      }
      
      await _service.deleteMenu(id);
      await fetchMenus();
      
      Get.snackbar(
        'Success',
        'Menu deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete menu: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Menu name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (selectedCategoryId.value == null) {
      Get.snackbar('Error', 'Please select a category',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Price is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    final price = double.tryParse(priceController.text);
    if (price == null || price < 0) {
      Get.snackbar('Error', 'Please enter a valid price',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    if (stockController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Stock is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    final stock = int.tryParse(stockController.text);
    if (stock == null || stock < 0) {
      Get.snackbar('Error', 'Please enter a valid stock',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
    return true;
  }

  void clearForm() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    stockController.clear();
    selectedCategoryId.value = null;
    selectedImageFile.value = null;
    imageUrl.value = null;
    isAvailable.value = true;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}