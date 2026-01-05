import 'dart:io';
import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/repositories/complete_profile_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:chiroku_cafe/utils/functions/validator.dart';
import 'package:chiroku_cafe/utils/services/permission_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileController extends GetxController {
  //================== Dependencies ===================//
  final _repository = CompleteProfileRepository();
  final _permissionService = PermissionService();
  final _customSnackbar = CustomSnackbar();
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
    final hasPermission = await _permissionService.requestStoragePermission();
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
        _customSnackbar.showSuccessSnackbar(
          AuthErrorModel.imageSelected().message,
        );
      }
    } catch (e) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.invalidAvatarFormat().message,
      );
    } finally {
      _isUploading.value = false;
    }
  }
  //

  //take foto with camera
  Future<void> takePhoto() async {
    //Request permission camera

    final hasPermission = await _permissionService
        .requestCameraPermission();
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
        _customSnackbar.showSuccessSnackbar(
          AuthErrorModel.capturePhoto().message,
        );
      }
    } catch (e) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.capturePhotoFailed().message,
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
  // Show confirmation dialog
  await Get.defaultDialog(
    title: 'Remove Photo',
    titleStyle: AppTypography.h5.copyWith(
      color: AppColors.brownDarker,
      fontWeight: FontWeight.bold,
    ),
    middleText: 'Are you sure you want to remove this photo?',
    middleTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.brownNormal,
    ),
    textConfirm: 'Remove',
    textCancel: 'Cancel',
    confirmTextColor: AppColors.white,
    cancelTextColor: AppColors.brownNormal,
    buttonColor: AppColors.alertNormal,
    onConfirm: () {
      _avatarFile.value = null;
      Get.back(); // Close dialog
      _customSnackbar.showSuccessSnackbar(
        AuthErrorModel.deleteAvatarFailed().message,
      );
    },
    onCancel: () {
      Get.back(); // Close dialog
    },
  );
}/// Upload avatar to storage and get URL
  Future<String?> _uploadAvatar() async {
    if (_avatarFile.value == null) return null;

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Upload avatar via repository
      final avatarUrl = await _repository.uploadAvatar(
        userId: userId,
        avatarFile: _avatarFile.value!,
      );

      return avatarUrl;
    } catch (e) {
      _customSnackbar.showErrorSnackbar(
       AuthErrorModel.uploadAvatarFailed().message,
      );
      return null;
    }
  }

  /// Complete user profile
  Future<void> completeProfile() async {
    // Validate form
    if (!nameFormKey.currentState!.validate()) {
      return;
    }

    // Check if user is authenticated
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      
        AuthErrorModel.failedLoadUser();
      
      // Get.offAllNamed(AppRoutes.signUp);
      return;
    }

    try {
      _isLoading.value = true;

      String? newAvatarUrl;
    if (_avatarFile.value != null) {
      print('Avatar file exists: ${_avatarFile.value!.path}');
      print('File size: ${await _avatarFile.value!.length()} bytes');
      
      newAvatarUrl = await _uploadAvatar();
      
      if (newAvatarUrl == null) {
        print('Avatar upload failed!');
        _isLoading.value = false;
        return;
      }
      print('Avatar uploaded successfully: $newAvatarUrl');
    } else {
      print('No avatar file selected');
    }

      // Complete profile via repository
      await _repository.completeProfile(
        userId: userId,
        fullName: nameController.text.trim(),
        avatarFile: avatarFile,
      );

      _customSnackbar.showSuccessSnackbar(
        AuthErrorModel.successAccount().message,
      );

      // Navigate to home screen
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      _customSnackbar.showErrorSnackbar(
        AuthErrorModel.updateProfileFailed().message,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
