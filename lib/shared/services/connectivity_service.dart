import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  
  final RxBool isOnline = true.obs;
  final Rx<List<ConnectivityResult>> connectionStatus = Rx<List<ConnectivityResult>>([ConnectivityResult.wifi]);

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
      log('❌ Failed to get connectivity: $e');
      isOnline.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    connectionStatus.value = result;
    isOnline.value = !result.contains(ConnectivityResult.none);
    
    if (isOnline.value) {
      log('✅ Device is online: $result');
    } else {
      log('📴 Device is offline');
    }
  }

  bool get isConnected => isOnline.value;
}