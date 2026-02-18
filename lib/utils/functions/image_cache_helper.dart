import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';

class ImageCacheHelper {
  // Custom cache manager untuk avatar
  static final CacheManager _avatarCacheManager = CacheManager(
    Config(
      'chiroku_avatar_cache',
      stalePeriod: const Duration(days: 120), // Cache selama 120 hari
      maxNrOfCacheObjects: 200, // Max 200 images
      repo: JsonCacheInfoRepository(databaseName: 'chiroku_avatar_cache'),
      fileService: HttpFileService(),
    ),
  );

  // Custom cache manager untuk menu images
  static final CacheManager _menuCacheManager = CacheManager(
    Config(
      'chiroku_menu_cache',
      stalePeriod: const Duration(days: 90), // Cache selama 90 hari
      maxNrOfCacheObjects: 500, // Max 500 menu images
      repo: JsonCacheInfoRepository(databaseName: 'chiroku_menu_cache'),
      fileService: HttpFileService(),
    ),
  );

  // ==================== AVATAR CACHE ====================

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

    // Handle local file path
    if (!imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: FileImage(file), fit: fit),
          ),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _avatarCacheManager,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: fit),
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

    // Handle local file path
    if (!imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: FileImage(file), fit: fit),
          ),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _avatarCacheManager,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: fit),
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
    );
  }

  // ==================== MENU IMAGE CACHE ====================

  static Widget cachedMenuImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Color? loadingColor,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackMenuImage(
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      );
    }

    // Handle local file path
    if (!imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            image: DecorationImage(image: FileImage(file), fit: fit),
          ),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _menuCacheManager,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
      placeholder: (context, url) => _buildLoadingMenuImage(
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        loadingColor: loadingColor,
      ),
      errorWidget: (context, url, error) {
        log('❌ Error loading menu image: $url - $error');
        return errorWidget ??
            _buildFallbackMenuImage(
              width: width,
              height: height,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
            );
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  // ==================== PRIVATE BUILDERS ====================

  static Widget _buildLoadingMenuImage({
    double? width,
    double? height,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Color? loadingColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? Colors.grey[600]!,
          ),
        ),
      ),
    );
  }

  static Widget _buildFallbackMenuImage({
    double? width,
    double? height,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: (width != null && height != null)
            ? (width < height ? width * 0.5 : height * 0.5)
            : 48,
        color: Colors.grey[600],
      ),
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
          style:
              textStyle ??
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

  static Future<void> precacheAvatar(
    BuildContext context,
    String? imageUrl,
  ) async {
    if (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http'))
      return;

    try {
      await _avatarCacheManager.downloadFile(imageUrl);
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
      if (url.isNotEmpty && url.startsWith('http')) {
        try {
          await _avatarCacheManager.downloadFile(url);
          successCount++;
          log('✅ Cached avatar: $url');
        } catch (e) {
          errorCount++;
          log('❌ Error caching avatar: $url - $e');
        }
      }
    }

    log('✅ Precached $successCount avatars (${errorCount} errors)');
  }

  static Future<void> precacheMenuImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http'))
      return;

    try {
      await _menuCacheManager.downloadFile(imageUrl);
      log('✅ Menu image precached: $imageUrl');
    } catch (e) {
      log('❌ Error precaching menu image: $e');
    }
  }

  static Future<void> precacheMenuImages(List<String> imageUrls) async {
    int successCount = 0;
    int errorCount = 0;

    for (final url in imageUrls) {
      if (url.isNotEmpty && url.startsWith('http')) {
        try {
          await _menuCacheManager.downloadFile(url);
          successCount++;
          log('✅ Cached menu image: $url');
        } catch (e) {
          errorCount++;
          log('❌ Error caching menu image: $url - $e');
        }
      }
    }

    log('✅ Precached $successCount menu images (${errorCount} errors)');
  }

  // ==================== CACHE INFO ====================

  static Future<bool> isImageCached(String imageUrl) async {
    if (!imageUrl.startsWith('http')) {
      return File(imageUrl).existsSync();
    }
    try {
      final fileInfo = await _avatarCacheManager.getFileFromCache(imageUrl);
      final isCached = fileInfo != null;
      if (isCached) {
        log('✅ Avatar cached: $imageUrl');
      } else {
        log('ℹ️ Avatar not cached: $imageUrl');
      }
      return isCached;
    } catch (e) {
      log('❌ Error checking avatar cache: $e');
      return false;
    }
  }

  static Future<bool> isAvatarCached(String imageUrl) async {
    if (!imageUrl.startsWith('http')) {
      return File(imageUrl).existsSync();
    }
    try {
      final fileInfo = await _avatarCacheManager.getFileFromCache(imageUrl);
      final isCached = fileInfo != null;
      if (isCached) {
        log('✅ Avatar cached: $imageUrl');
      } else {
        log('ℹ️ Avatar not cached: $imageUrl');
      }
      return isCached;
    } catch (e) {
      log('❌ Error checking avatar cache: $e');
      return false;
    }
  }

  static Future<bool> isMenuImageCached(String imageUrl) async {
    if (!imageUrl.startsWith('http')) {
      return File(imageUrl).existsSync();
    }
    try {
      final fileInfo = await _menuCacheManager.getFileFromCache(imageUrl);
      final isCached = fileInfo != null;
      if (isCached) {
        log('✅ Menu image cached: $imageUrl');
      } else {
        log('ℹ️ Menu image not cached: $imageUrl');
      }
      return isCached;
    } catch (e) {
      log('❌ Error checking menu image cache: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getCacheInfo() async {
    return {
      'avatar': {
        'cacheExists': true,
        'message': 'Avatar cache manager initialized',
        'stalePeriod': '120 days',
        'maxObjects': 200,
      },
      'menu': {
        'cacheExists': true,
        'message': 'Menu cache manager initialized',
        'stalePeriod': '90 days',
        'maxObjects': 500,
      },
    };
  }

  // ==================== CACHE MANAGEMENT ====================

  static Future<void> clearCache() async {
    try {
      await _avatarCacheManager.emptyCache();
      log('✅ All avatar cache cleared');
    } catch (e) {
      log('❌ Error clearing avatar cache: $e');
      rethrow;
    }
  }

  static Future<void> clearAvatarCache() async {
    try {
      await _avatarCacheManager.emptyCache();
      log('✅ All avatar cache cleared');
    } catch (e) {
      log('❌ Error clearing avatar cache: $e');
      rethrow;
    }
  }

  static Future<void> clearMenuCache() async {
    try {
      await _menuCacheManager.emptyCache();
      log('✅ All menu cache cleared');
    } catch (e) {
      log('❌ Error clearing menu cache: $e');
      rethrow;
    }
  }

  static Future<void> clearAllCache() async {
    try {
      await _avatarCacheManager.emptyCache();
      await _menuCacheManager.emptyCache();
      log('✅ All cache cleared (avatars & menus)');
    } catch (e) {
      log('❌ Error clearing all cache: $e');
      rethrow;
    }
  }

  static Future<void> clearImageCache(
    String imageUrl, {
    bool isMenuImage = false,
  }) async {
    try {
      if (isMenuImage) {
        await _menuCacheManager.removeFile(imageUrl);
        log('✅ Menu image cache cleared for: $imageUrl');
      } else {
        await _avatarCacheManager.removeFile(imageUrl);
        log('✅ Avatar cache cleared for: $imageUrl');
      }
    } catch (e) {
      log('❌ Error clearing image cache: $e');
      rethrow;
    }
  }
}
