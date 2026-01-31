import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      log('❌ Connectivity check error: $e');
      isOnline.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any connection is available
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    isOnline.value = hasConnection;
    log('Connectivity status: ${isOnline.value ? "ONLINE" : "OFFLINE"}');
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return isOnline.value;
    } catch (e) {
      log('❌ Connection check error: $e');
      return false;
    }
  }
}
