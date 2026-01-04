import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        await _showPermissionDialog(
          title: 'Camera Permission Required',
          message: 'Please grant camera permission from app settings to take photos.',
          icon: Icons.camera_alt,
        );
        return false;
      }
      return false;
    }
    
    if (status.isPermanentlyDenied) {
      await _showPermissionDialog(
        title: 'Camera Permission Required',
        message: 'Please grant camera permission from app settings to take photos.',
        icon: Icons.camera_alt,
      );
      return false;
    }
    
    return false;
  }

  /// Request storage/photos permission
  Future<bool> requestStoragePermission() async {
    // For Android 13+ (API 33+), use photos permission
    // For older versions, use storage permission
    PermissionStatus status;
    
    if (await _isAndroid13OrHigher()) {
      status = await Permission.photos.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.photos.request();
        if (result.isGranted) {
          return true;
        } else if (result.isPermanentlyDenied) {
          await _showPermissionDialog(
            title: 'Photos Permission Required',
            message: 'Please grant photos permission from app settings to select images.',
            icon: Icons.photo_library,
          );
          return false;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          title: 'Photos Permission Required',
          message: 'Please grant photos permission from app settings to select images.',
          icon: Icons.photo_library,
        );
        return false;
      }
    } else {
      status = await Permission.storage.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        } else if (result.isPermanentlyDenied) {
          await _showPermissionDialog(
            title: 'Storage Permission Required',
            message: 'Please grant storage permission from app settings to select images.',
            icon: Icons.photo_library,
          );
          return false;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showPermissionDialog(
          title: 'Storage Permission Required',
          message: 'Please grant storage permission from app settings to select images.',
          icon: Icons.photo_library,
        );
        return false;
      }
    }
    
    return false;
  }

  /// Check if Android version is 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    // You might need to add device_info_plus package for this
    // For now, we'll request photos permission by default
    return true;
  }

  /// Show permission dialog with option to open settings
  Future<void> _showPermissionDialog({
    required String title,
    required String message,
    required IconData icon,
  }) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppColors.alertNormal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.brownDark,
          ),
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
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Open Settings',
              style: AppTypography.button.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show loading dialog while checking permissions
  void showPermissionLoadingDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.brownNormal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Checking permissions...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.brownDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Request all necessary permissions for image picking
  Future<bool> requestAllImagePermissions() async {
    showPermissionLoadingDialog();
    
    final storageGranted = await requestStoragePermission();
    
    Get.back(); // Close loading dialog
    
    if (!storageGranted) {
      _showPermissionSnackbar(
        'Permission Denied',
        'Storage permission is required to select images',
        false,
      );
      return false;
    }
    
    return true;
  }

  /// Request all necessary permissions for camera
  Future<bool> requestAllCameraPermissions() async {
    showPermissionLoadingDialog();
    
    final cameraGranted = await requestCameraPermission();
    
    Get.back(); // Close loading dialog
    
    if (!cameraGranted) {
      _showPermissionSnackbar(
        'Permission Denied',
        'Camera permission is required to take photos',
        false,
      );
      return false;
    }
    
    return true;
  }

  /// Show permission snackbar
  void _showPermissionSnackbar(String title, String message, bool isSuccess) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess ? AppColors.successNormal : AppColors.alertNormal,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isSuccess ? Icons.check_circle : Icons.error_outline,
        color: AppColors.white,
      ),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      titleText: Text(
        title,
        style: AppTypography.h6.copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}