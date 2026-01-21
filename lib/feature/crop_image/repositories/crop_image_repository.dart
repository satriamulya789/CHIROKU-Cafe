import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CropImageRepository {
  /// Save and convert image to WebP
  Future<File?> convertToWebp(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String fileName = p.basenameWithoutExtension(imageFile.path);
      final String targetPath = p.join(tempDir.path, '$fileName.webp');

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: 80,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete temporary files if needed
  Future<void> clearCache() async {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}
