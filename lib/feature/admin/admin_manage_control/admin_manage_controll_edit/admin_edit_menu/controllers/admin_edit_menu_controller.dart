import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/models/admin_edit_category_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/services/admin_edit_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chiroku_cafe/feature/crop_image/services/crop_image_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';

class AdminEditMenuController extends GetxController {
  final MenuService _service = MenuService();
  final ImagePicker _picker = ImagePicker();
  final _cropService = CropImageService();
  final snackbar = CustomSnackbar();

  final menus = <MenuModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final searchQuery = ''.obs;

  // Stream subscriptions
  StreamSubscription<List<MenuModel>>? _menusSubscription;

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
    _initMenusStream(); // ✅ Subscribe to menus stream
    fetchCategories();
  }

  @override
  void onClose() {
    _menusSubscription?.cancel();
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

  // ==================== INIT MENUS STREAM ====================
  void _initMenusStream() {
    try {
      log('👁️ Controller: Setting up menus stream...');
      _menusSubscription = _service.watchMenus().listen(
        (menusList) {
          log('📥 Controller: Received ${menusList.length} menus from stream');
          menus.value = menusList;
        },
        onError: (error) {
          log('❌ Controller: Menus stream error: $error');
          snackbar.showErrorSnackbar('Error loading menus: $error');
        },
      );
      log('✅ Controller: Menus stream initialized');
    } catch (e) {
      log('❌ Controller: Error initializing menus stream: $e');
      snackbar.showErrorSnackbar('Failed to initialize menus stream: $e');
    }
  }

  // ==================== FETCH MENUS (DEPRECATED - Use stream instead) ====================
  Future<void> refreshMenus() async {
    try {
      isLoading.value = true;
      await _service.fetchMenus();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to fetch menus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      categories.value = await _service.fetchCategories();
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to fetch categories: $e');
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
        final processedFile = await _cropService.processImage(
          imageFile: File(image.path),
          isCircle: false,
        );
        if (processedFile != null) {
          selectedImageFile.value = processedFile;
        }
      }
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to pick image: $e');
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
        final processedFile = await _cropService.processImage(
          imageFile: File(image.path),
          isCircle: false,
        );
        if (processedFile != null) {
          selectedImageFile.value = processedFile;
        }
      }
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to take photo: $e');
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
      snackbar.showErrorSnackbar('Failed to upload image: $e');
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

      // Stream will auto-update UI
      Get.back();
      snackbar.showSuccessSnackbar('Menu created successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to create menu: $e');
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

      // Stream will auto-update UI
      Get.back();
      snackbar.showSuccessSnackbar('Menu updated successfully');
    } catch (e) {
      snackbar.showErrorSnackbar('Failed to update menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMenu(int id, String? imageUrl) async {
    try {
      isLoading.value = true;

      await _service.deleteMenu(id);

      // Delete image from storage only after successful menu deletion
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _service.deleteImage(imageUrl);
      }

      // Stream will auto-update UI
      snackbar.showSuccessSnackbar('Menu deleted successfully');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('23503')) {
        _showDisableInsteadOfDeleteDialog(id);
      } else {
        snackbar.showErrorSnackbar('Failed to delete menu: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showDisableInsteadOfDeleteDialog(int id) {
    Get.dialog(
      AlertDialog(
        title: Text('Cannot Delete Menu', style: AppTypography.h5),
        content: Text(
          'This menu has already been ordered and cannot be deleted to maintain order history. Would you like to set it to "Not Available" instead?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(
                color: AppColors.brownNormal,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _service.toggleMenuAvailability(id, false);
              // Stream will auto-update UI
              snackbar.showSuccessSnackbar('Menu status set to Not Available');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
            ),
            child: Text(
              'Set to Not Available',
              style: AppTypography.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Menu name is required');
      return false;
    }
    if (selectedCategoryId.value == null) {
      snackbar.showErrorSnackbar('Please select a category');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Price is required');
      return false;
    }
    final price = double.tryParse(priceController.text);
    if (price == null || price < 0) {
      snackbar.showErrorSnackbar('Please enter a valid price');
      return false;
    }
    if (stockController.text.trim().isEmpty) {
      snackbar.showErrorSnackbar('Stock is required');
      return false;
    }
    final stock = int.tryParse(stockController.text);
    if (stock == null || stock < 0) {
      snackbar.showErrorSnackbar('Please enter a valid stock');
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
