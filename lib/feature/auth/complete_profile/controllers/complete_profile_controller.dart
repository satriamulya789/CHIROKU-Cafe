import 'dart:io';

import 'package:chiroku_cafe/feature/auth/complete_profile/repositories/complete_profile_repositories.dart';
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        _avatarFile.value = File(pickedFile.path);
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

  Future<void> removeAvatar() async {
    _avatarFile.value = null;
  }
}
