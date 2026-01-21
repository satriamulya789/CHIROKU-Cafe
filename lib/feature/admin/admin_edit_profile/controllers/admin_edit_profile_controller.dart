import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_edit_profile/models/admin_edit_profile_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_edit_profile/repositories/admin_edit_profile_repositories.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chiroku_cafe/feature/crop_image/services/crop_image_service.dart';

class EditProfileController extends GetxController {
  final UserProfileRepository _repository = UserProfileRepository();
  final ImagePicker _picker = ImagePicker();
  final _cropService = CropImageService();
  final customSnackbar = CustomSnackbar();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final userProfile = Rxn<UserProfileModel>();
  final selectedImage = Rxn<File>();

  String get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final profile = await _repository.getUserProfile(currentUserId);
      userProfile.value = profile;

      fullNameController.text = profile.fullName;
      emailController.text = profile.email;
    } catch (e) {
      customSnackbar.showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final processedFile = await _cropService.processImage(
          imageFile: File(pickedFile.path),
          isCircle: true,
        );
        if (processedFile != null) {
          selectedImage.value = processedFile;
          await uploadAvatar();
        }
      }
    } catch (e) {
      customSnackbar.showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final processedFile = await _cropService.processImage(
          imageFile: File(pickedFile.path),
          isCircle: true,
        );
        if (processedFile != null) {
          selectedImage.value = processedFile;
          await uploadAvatar();
        }
      }
    } catch (e) {
      customSnackbar.showErrorSnackbar('Failed to take photo: $e');
    }
  }

  Future<void> uploadAvatar() async {
    if (selectedImage.value == null) return;

    try {
      isUploadingImage.value = true;

      final String? newAvatarUrl = await _repository.uploadAndUpdateAvatar(
        userId: currentUserId,
        imageFile: selectedImage.value!,
        oldAvatarUrl: userProfile.value?.avatarUrl,
      );

      if (newAvatarUrl != null) {
        userProfile.value = userProfile.value?.copyWith(
          avatarUrl: newAvatarUrl,
        );

        customSnackbar.showSuccessSnackbar('Avatar updated successfully');
      }
    } catch (e) {
      customSnackbar.showErrorSnackbar(
        'Failed to upload avatar: ${e.toString()}',
      );
    } finally {
      isUploadingImage.value = false;
      selectedImage.value = null;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await _repository.updateUserProfile(
        userId: currentUserId,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
      );

      userProfile.value = userProfile.value?.copyWith(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        updatedAt: DateTime.now(),
      );

      customSnackbar.showSuccessSnackbar('Profile updated successfully');

      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(result: true);
    } catch (e) {
      customSnackbar.showErrorSnackbar(
        'Failed to update profile: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Choose Image Source',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
