import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String _githubRepo = 'satriamulya789/CHIROKU-Cafe';

  /// Check for updates from GitHub Releases
  Future<void> checkForUpdate() async {
    try {
      log('🔄 UpdateService: Checking for updates...');
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      final release = await _getLatestRelease();
      if (release == null) {
        log('✅ UpdateService: No release found or error fetching.');
        return;
      }

      final String latestVersion = _cleanVersion(release['tag_name']);
      final String downloadUrl = _getApkUrl(release['assets']);

      log('🔄 UpdateService: Current=$currentVersion, Latest=$latestVersion');

      if (_isNewerVersion(currentVersion, latestVersion)) {
        log('🚀 UpdateService: New version available! URL: $downloadUrl');
        _showUpdateDialog(latestVersion, release['body'] ?? '', downloadUrl);
      } else {
        log('✅ UpdateService: App is up to date.');
      }
    } catch (e) {
      log('❌ UpdateService: Error checking for update: $e');
    }
  }

  /// Get latest release from GitHub API
  Future<Map<String, dynamic>?> _getLatestRelease() async {
    try {
      final Uri url = Uri.parse(
        'https://api.github.com/repos/$_githubRepo/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        log(
          '❌ UpdateService: Failed to get latest release. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      log('❌ UpdateService: Error fetching release: $e');
      return null;
    }
  }

  /// Extract APK download URL from assets
  String _getApkUrl(List<dynamic> assets) {
    if (assets.isEmpty) return '';
    try {
      final apkAsset = assets.firstWhere(
        (asset) => asset['name'].toString().endsWith('.apk'),
        orElse: () => null,
      );
      return apkAsset != null ? apkAsset['browser_download_url'] : '';
    } catch (e) {
      return '';
    }
  }

  /// Remove 'v' prefix if present
  String _cleanVersion(String version) {
    return version.startsWith('v') ? version.substring(1) : version;
  }

  /// Compare semantic versions
  bool _isNewerVersion(String current, String latest) {
    try {
      List<int> c = current.split('+')[0].split('.').map(int.parse).toList();
      List<int> l = latest.split('+')[0].split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        int cv = i < c.length ? c[i] : 0;
        int lv = i < l.length ? l[i] : 0;
        if (lv > cv) return true;
        if (lv < cv) return false;
      }
      return false;
    } catch (e) {
      log('❌ UpdateService: Error parsing versions: $e');
      return false; // Safely assume no update if parsing fails
    }
  }

  /// Show update dialog
  void _showUpdateDialog(String version, String notes, String downloadUrl) {
    if (downloadUrl.isEmpty) {
      log('❌ UpdateService: Download URL is empty, skipping dialog.');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Update Available 🚀'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A new version $version is available!'),
            const SizedBox(height: 10),
            const Text(
              'Release Notes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(notes, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _downloadAndInstall(downloadUrl);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Download and install using ota_update
  Future<void> _downloadAndInstall(String url) async {
    try {
      log('📥 UpdateService: Starting download from $url');

      // Show progress dialog or toast if needed, but ota_update handles notification progress usually
      OtaUpdate().execute(url, destinationFilename: 'chiroku_update.apk').listen((
        OtaEvent event,
      ) {
        log('📥 UpdateService: Status ${event.status}, Value: ${event.value}');
        // You can implement a progress dialog update here if you want in-app feedback
      });
    } catch (e) {
      log('❌ UpdateService: Update failed: $e');
    }
  }
}
