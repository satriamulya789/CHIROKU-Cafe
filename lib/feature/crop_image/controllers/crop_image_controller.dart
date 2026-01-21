import 'dart:io';
import 'package:chiroku_cafe/feature/crop_image/services/crop_image_service.dart';
import 'package:get/get.dart';

class CropImageController extends GetxController {
  final CropImageService _service = CropImageService();

  final isProcessing = false.obs;

  Future<File?> pickAndProcessImage({bool isCircle = false}) async {
    try {
      isProcessing.value = true;
      final file = await _service.showImagePicker(isCircle: isCircle);
      return file;
    } finally {
      isProcessing.value = false;
    }
  }
}
