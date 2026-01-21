import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:chiroku_cafe/feature/crop_image/repositories/crop_image_repository.dart';
import 'package:chiroku_cafe/feature/crop_image/widgets/image_picker_bottom_sheet.dart';
import 'package:get/get.dart';

class CropImageService {
  /// Show image picker bottom sheet and process the result
  Future<File?> showImagePicker({bool isCircle = false}) async {
    File? result;
    await Get.bottomSheet(
      ImagePickerBottomSheet(
        onCameraTap: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );
          if (image != null) {
            result = await processImage(
              imageFile: File(image.path),
              isCircle: isCircle,
            );
          }
        },
        onGalleryTap: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );
          if (image != null) {
            result = await processImage(
              imageFile: File(image.path),
              isCircle: isCircle,
            );
          }
        },
      ),
    );
    return result;
  }

  /// Crop the selected image
  Future<File?> cropImage({
    required File imageFile,
    bool isCircle = false,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.brownNormal,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isCircle
                ? CropAspectRatioPreset.square
                : CropAspectRatioPreset.original,
            lockAspectRatio: isCircle,
            activeControlsWidgetColor: AppColors.brownNormal,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: isCircle,
            resetAspectRatioEnabled: !isCircle,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  final _repository = CropImageRepository();

  /// Convert image to WebP format using repository
  Future<File?> convertToWebp(File imageFile) async {
    return _repository.convertToWebp(imageFile);
  }

  /// Combined method: Crop then convert to WebP
  Future<File?> processImage({
    required File imageFile,
    bool isCircle = false,
  }) async {
    // 1. Crop
    final cropped = await cropImage(imageFile: imageFile, isCircle: isCircle);
    if (cropped == null) return null;

    // 2. Convert to WebP
    final webp = await convertToWebp(cropped);
    return webp;
  }
}
