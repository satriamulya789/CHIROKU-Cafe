import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AvatarCacheService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'avatars';

  // Get cache directory
  Future<Directory> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/avatar_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Get cached avatar path
  Future<String?> getCachedAvatarPath(String userId) async {
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$userId.jpg');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      log('❌ Error getting cached avatar: $e');
      return null;
    }
  }

  // Download and cache avatar
  Future<String?> downloadAndCacheAvatar(String avatarUrl, String userId) async {
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$userId.jpg');

      // Download from Supabase
      final response = await _supabase.storage
          .from(_bucketName)
          .download(avatarUrl.split('/').last);

      await file.writeAsBytes(response);
      log('✅ Avatar cached for user: $userId');
      return file.path;
    } catch (e) {
      log('❌ Error downloading avatar: $e');
      return null;
    }
  }

  // Upload avatar to Supabase
  Future<String?> uploadAvatar(XFile imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = path.extension(imageFile.path);
      final fileName = '$userId${DateTime.now().millisecondsSinceEpoch}$fileExt';

      await _supabase.storage.from(_bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      
      // Cache locally
      final dir = await _cacheDir;
      final cachedFile = File('${dir.path}/$userId.jpg');
      await cachedFile.writeAsBytes(bytes);

      log('✅ Avatar uploaded: $fileName');
      return publicUrl;
    } catch (e) {
      log('❌ Error uploading avatar: $e');
      return null;
    }
  }

  // Queue avatar upload for offline mode
  Future<String> queueAvatarUpload(XFile imageFile, String userId) async {
    try {
      // Save to local cache
      final dir = await _cacheDir;
      final cachedFile = File('${dir.path}/$userId.jpg');
      final bytes = await imageFile.readAsBytes();
      await cachedFile.writeAsBytes(bytes);

      // Save to pending uploads
      final pendingDir = Directory('${dir.path}/pending');
      if (!await pendingDir.exists()) {
        await pendingDir.create();
      }
      final pendingFile = File('${pendingDir.path}/$userId.jpg');
      await pendingFile.writeAsBytes(bytes);

      log('✅ Avatar queued for upload: $userId');
      return cachedFile.path;
    } catch (e) {
      log('❌ Error queuing avatar: $e');
      rethrow;
    }
  }

  // Process pending avatar uploads
  Future<void> processPendingUploads() async {
    try {
      final dir = await _cacheDir;
      final pendingDir = Directory('${dir.path}/pending');
      
      if (!await pendingDir.exists()) return;

      final files = pendingDir.listSync();
      for (var file in files) {
        if (file is File) {
          final userId = path.basenameWithoutExtension(file.path);
          final bytes = await file.readAsBytes();
          
          try {
            final fileName = '$userId${DateTime.now().millisecondsSinceEpoch}.jpg';
            await _supabase.storage.from(_bucketName).uploadBinary(
                  fileName,
                  bytes,
                  fileOptions: const FileOptions(upsert: true),
                );
            
            // Delete from pending
            await file.delete();
            log('✅ Pending avatar uploaded: $userId');
          } catch (e) {
            log('❌ Failed to upload pending avatar: $e');
          }
        }
      }
    } catch (e) {
      log('❌ Error processing pending uploads: $e');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final dir = await _cacheDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      log('✅ Avatar cache cleared');
    } catch (e) {
      log('❌ Error clearing cache: $e');
    }
  }
}