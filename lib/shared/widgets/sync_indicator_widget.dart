import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/offline_user_service.dart';
import '../services/connectivity_service.dart';

class SyncIndicatorWidget extends StatelessWidget {
  const SyncIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Get.find<OfflineUserService>();
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(() {
      if (userService.isSyncing.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Syncing...',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        );
      }

      if (!connectivityService.isConnected) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 14, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Offline Mode',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, size: 14, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Synced',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      );
    });
  }
}