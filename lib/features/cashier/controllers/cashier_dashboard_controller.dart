import 'package:get/get.dart';
import '../models/cashier_stats_model.dart';
import '../repositories/cashier_repository.dart';
import 'dart:async';

class CashierDashboardController extends GetxController {
  final CashierRepository _repository = CashierRepository();

  // Observable variables
  final Rx<CashierStats> stats = CashierStats(
    totalOrders: 0,
    pendingOrders: 0,
    completedOrders: 0,
    totalRevenue: 0,
    tablesOccupied: 0,
    tablesAvailable: 0,
  ).obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription? _statsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
    _setupRealtimeUpdates();
  }

  @override
  void onClose() {
    _statsSubscription?.cancel();
    super.onClose();
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final dashboardStats = await _repository.getDashboardStats();
      stats.value = dashboardStats;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Setup realtime updates
  void _setupRealtimeUpdates() {
    _statsSubscription = _repository.watchDashboardStats().listen(
      (newStats) {
        stats.value = newStats;
      },
      onError: (error) {
        errorMessage.value = error.toString();
      },
    );
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardStats();
  }

  /// Get pending orders count
  Future<int> getPendingOrdersCount() async {
    try {
      return await _repository.getPendingOrdersCount();
    } catch (e) {
      return 0;
    }
  }

  /// Get today's revenue
  Future<double> getTodayRevenue() async {
    try {
      return await _repository.getTodayRevenue();
    } catch (e) {
      return 0;
    }
  }
}
