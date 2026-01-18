import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminMenuFormPage extends GetView<AdminEditMenuController> {
  final int? menuId;
  final bool isEdit;

  const AdminMenuFormPage({
    super.key,
    this.menuId,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildFormSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.brownLight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.brownDarkActive,
                  size: 20,
                ),
                onPressed: () {
                  controller.clearForm();
                  Get.back();
                },
              ),
              Expanded(
                child: Text(
                  isEdit ? 'Edit Menu' : 'Add New Menu',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.brownDarkActive,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Image',
            style: AppTypography.h6.copyWith(
              color: AppColors.brownDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final imageFile = controller.selectedImageFile.value;
            final imageUrl = controller.imageUrl.value;

            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.brownLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brownNormal.withOpacity(0.3),
                ),
              ),
              child: imageFile != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: controller.removeImage,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : imageUrl != null && imageUrl.isNotEmpty
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: controller.removeImage,
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildPlaceholder(),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brownNormal,
                    side: const BorderSide(color: AppColors.brownNormal),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brownNormal,
                    side: const BorderSide(color: AppColors.brownNormal),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: AppColors.brownNormal.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Add menu image',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.brownNormal.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Details',
            style: AppTypography.h6.copyWith(
              color: AppColors.brownDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nameController,
            decoration: _inputDecoration('Menu Name *'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<int>(
                value: controller.selectedCategoryId.value,
                decoration: _inputDecoration('Category *'),
                hint: const Text('Select Category'),
                items: controller.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedCategoryId.value = value;
                },
              )),
          const SizedBox(height: 16),
          TextField(
            controller: controller.priceController,
            decoration: _inputDecoration('Price *'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.stockController,
            decoration: _inputDecoration('Stock *'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.descriptionController,
            decoration: _inputDecoration('Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Obx(() => SwitchListTile(
                title: Text(
                  'Available',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.brownDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  controller.isAvailable.value
                      ? 'Menu is available for order'
                      : 'Menu is not available',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brownNormal,
                  ),
                ),
                value: controller.isAvailable.value,
                onChanged: (value) {
                  controller.isAvailable.value = value;
                },
                activeColor: AppColors.successNormal,
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isLoading = controller.isLoading.value || controller.isUploadingImage.value;
      
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      controller.clearForm();
                      Get.back();
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.brownNormal),
                foregroundColor: AppColors.brownNormal,
              ),
              child: Text(
                'Cancel',
                style: AppTypography.button,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (isEdit) {
                        controller.updateMenu(menuId!);
                      } else {
                        controller.createMenu();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.brownNormal,
                disabledBackgroundColor: AppColors.brownNormal.withOpacity(0.5),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      isEdit ? 'Update Menu' : 'Create Menu',
                      style: AppTypography.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.brownNormal,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brownNormal, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.brownNormal.withOpacity(0.3)),
      ),
    );
  }
}