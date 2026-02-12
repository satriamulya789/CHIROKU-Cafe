import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class ImageCacheHelper {
  // Custom cache manager dengan konfigurasi persistent
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'chiroku_avatar_cache',
      stalePeriod: const Duration(days: 120), // Cache selama 120 hari
      maxNrOfCacheObjects: 200, // Max 200 images
      repo: JsonCacheInfoRepository(databaseName: 'chiroku_avatar_cache'),
      fileService: HttpFileService(),
    ),
  );

  // Cache avatar with fallback
  static Widget cachedAvatar({
    required String? imageUrl,
    double size = 50,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
    Color? iconColor,
    Color? loadingColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackAvatar(
        size,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _cacheManager,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => _buildLoadingAvatar(
        size,
        backgroundColor: backgroundColor,
        loadingColor: loadingColor,
      ),
      errorWidget: (context, url, error) {
        log('❌ Error loading avatar: $url - $error');
        return _buildFallbackAvatar(
          size,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      // ❌ REMOVE ALL RESIZE PARAMETERS - not supported with regular CacheManager
      // memCacheWidth: 200,
      // memCacheHeight: 200,
      // maxWidthDiskCache: 200,
      // maxHeightDiskCache: 200,
    );
  }

  // Cache avatar with initial letter fallback
  static Widget cachedAvatarWithInitial({
    required String? imageUrl,
    required String userName,
    double size = 50,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
    Color? textColor,
    Color? loadingColor,
    TextStyle? textStyle,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildInitialAvatar(
        size,
        userName: userName,
        backgroundColor: backgroundColor,
        textColor: textColor,
        textStyle: textStyle,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _cacheManager,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => _buildLoadingAvatar(
        size,
        backgroundColor: backgroundColor,
        loadingColor: loadingColor,
      ),
      errorWidget: (context, url, error) {
        log('❌ Error loading avatar: $url - $error');
        return _buildInitialAvatar(
          size,
          userName: userName,
          backgroundColor: backgroundColor,
          textColor: textColor,
          textStyle: textStyle,
        );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      // ❌ REMOVE ALL RESIZE PARAMETERS
    );
  }

  static Widget _buildLoadingAvatar(
    double size, {
    Color? backgroundColor,
    Color? loadingColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              loadingColor ?? Colors.grey[600]!,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFallbackAvatar(
    double size, {
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: iconColor ?? Colors.grey[600],
      ),
    );
  }

  static Widget _buildInitialAvatar(
    double size, {
    required String userName,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Center(
        child: Text(
          initial,
          style: textStyle ??
              TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.grey[600],
              ),
        ),
      ),
    );
  }

  // ==================== PRECACHE METHODS ====================
  
  static Future<void> precacheAvatar(BuildContext context, String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    try {
      await _cacheManager.downloadFile(imageUrl);
      log('✅ Avatar precached: $imageUrl');
    } catch (e) {
      log('❌ Error precaching avatar: $e');
    }
  }

  static Future<void> precacheAvatars(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    int successCount = 0;
    int errorCount = 0;

    for (final url in imageUrls) {
      if (url.isNotEmpty) {
        try {
          await _cacheManager.downloadFile(url);
          successCount++;
          log('✅ Cached: $url');
        } catch (e) {
          errorCount++;
          log('❌ Error caching: $url - $e');
        }
      }
    }
    
    log('✅ Precached $successCount avatars (${errorCount} errors)');
  }

  // ==================== CACHE INFO ====================
  
  static Future<bool> isImageCached(String imageUrl) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      final isCached = fileInfo != null;
      if (isCached) {
        log('✅ Image cached: $imageUrl');
      } else {
        log('ℹ️ Image not cached: $imageUrl');
      }
      return isCached;
    } catch (e) {
      log('❌ Error checking cache: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getCacheInfo() async {
    return {
      'cacheExists': true,
      'message': 'Cache manager initialized',
      'stalePeriod': '120 days',
      'maxObjects': 200,
    };
  }

  // ==================== CACHE MANAGEMENT ====================
  
  static Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      log('✅ All avatar cache cleared');
    } catch (e) {
      log('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  static Future<void> clearImageCache(String imageUrl) async {
    try {
      await _cacheManager.removeFile(imageUrl);
      log('✅ Image cache cleared for: $imageUrl');
    } catch (e) {
      log('❌ Error clearing image cache: $e');
      rethrow;
    }
  }
}