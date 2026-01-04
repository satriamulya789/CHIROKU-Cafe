import 'dart:io';
import 'package:chiroku_cafe/feature/auth/complete_profile/repositories/complete_profile_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/utils/services/permission_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileController extends GetxController {
  //================== Dependencies ===================//
  final _repository = CompleteProfileRepository();
  final _permissionService = PermissionService();
  final supabase = Supabase.instance.client;

  //================== Form ===================//
  final nameController = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();

  final _avatarFile = Rx<File?>(null);
  File? get avatarFile => _avatarFile.value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isUploading = false.obs;
  bool get isUploading => _isUploading.value;

  //================== Methods ===================//
  //load existing user profile

  @override
  void onInit() {
    super.onInit();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final profile = await _repository.getUserProfile(userId);
      if (profile != null) {
        nameController.text = profile.fullName;
      }
    } catch (e) {
      throw AuthErrorModel.failedLoadUser();
    }
  }

  Future<void> pickImage() async {
    //Request permission storage/gallery
    final hasPermission = await _permissionService.requestAllImagePermissions();
    if (!hasPermission) return;

    try {
      _isUploading.value = true;

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        _avatarFile.value = File(pickedFile.path);
        Get.snackbar(
          'Success',
          AuthErrorModel.imageSelected().message,
          backgroundColor: AppColors.successNormal,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        AuthErrorModel.invalidAvatarFormat().message,
        backgroundColor: AppColors.alertNormal,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: AppColors.white),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    }
  }
  //

  //take foto with camera
  Future<void> takePhoto() async {
    //Request permission camera

    final hasPermission = await _permissionService
        .requestAllCameraPermissions();
    if (!hasPermission) return;

    try {
      _isUploading.value = true;

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _avatarFile.value = File(pickedFile.path);
        Get.snackbar(
          'Success',
          AuthErrorModel.capturePhoto().message,
          backgroundColor: AppColors.successNormal,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        AuthErrorModel.capturePhotoFailed().message,
        backgroundColor: AppColors.alertNormal,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: AppColors.white),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Show image source selection dialog
  Future<void> selectImageSource() async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: AppTypography.h5.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.brownNormal,
              ),
              title: Text(
                'Gallery',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.black,
                ),
              ),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.brownNormal,
              ),
              title: Text(
                'Camera',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.black,
                ),
              ),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

   /// Remove selected avatar
  Future<void> removeAvatar() async {
    _avatarFile.value = null;
    
  }

   @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
