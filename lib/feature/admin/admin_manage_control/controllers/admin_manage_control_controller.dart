import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_sync_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/repositories/admin_edit_menu_repositories.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/services/admin_edit_menu_sync_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/services/admin_manage_controll_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

class AdminManageControlController extends GetxController {
  final AdminManageControlService _service = AdminManageControlService();
  final snackbar = CustomSnackbar();
  final NetworkInfo _networkInfo = NetworkInfoImpl(Connectivity());

  final currentTabIndex = 0.obs;
  final isLoadingStats = false.obs;
  final isOnline = true.obs;
  final stats = AdminStatsModel.empty().obs;
  final tabs = <AdminTabModel>[].obs;

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<AdminStatsModel>? _statsSubscription;

  // Lazy getters — resolved on demand, not during onInit
  AdminEditUserController get userController =>
      Get.find<AdminEditUserController>();
  AdminEditMenuController get menuController =>
      Get.find<AdminEditMenuController>();
  AdminEditCategoryController get categoryController =>
      Get.find<AdminEditCategoryController>();
  AdminEditTableController get tableController =>
      Get.find<AdminEditTableController>();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenToConnectivity();
    _loadTabs();
    _watchStats();
    _initSyncServices();
  }

  void _initSyncServices() {
    try {
      // Initialize CategorySyncService
      if (Get.isRegistered<CategorySyncService>()) {
        Get.find<CategorySyncService>();
      } else {
        log('⚠️ CategorySyncService not registered');
      }

      // Initialize AdminEditMenuSyncService
      if (Get.isRegistered<AdminEditMenuSyncService>()) {
        Get.find<AdminEditMenuSyncService>();
      } else {
        log(
          '⚠️ AdminEditMenuSyncService not registered, forcing initialization',
        );
        Get.put(
          AdminEditMenuSyncService(
            Get.find<DatabaseHelper>().database,
            Get.find<NetworkInfo>(),
            MenuRepositories(),
          ),
          permanent: true,
        );
      }
      log('🔄 Sync services initialized');
    } catch (e) {
      log('⚠️ Failed to initialize sync services: $e');
    }
  }

  // ==================== CONNECTIVITY ====================
  Future<void> _initConnectivity() async {
    isOnline.value = await _networkInfo.isConnected;
    log(
      '🌐 Controller: Initial connectivity - ${isOnline.value ? "Online" : "Offline"}',
    );
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      log(
        '🔄 Controller: Connectivity changed to ${connected ? "Online" : "Offline"}',
      );
      isOnline.value = connected;
      if (connected) {
        snackbar.showSuccessSnackbar('🌐 Back online! Refreshing data...');
        _refreshAllData();
      } else {
        snackbar.showInfoSnackbar('📴 Offline mode - Using local data');
      }
    });
  }

  void _loadTabs() {
    tabs.value = _service.getTabList();
    log('📑 Loaded ${tabs.length} tabs');
  }

  Future<void> _refreshAllData() async {
    await refreshCurrentTab();
  }

  // ==================== REAL-TIME STATS STREAM ====================
  /// Subscribes to a reactive stream from the local DB.
  /// Stats update instantly whenever any table changes — online or offline.
  void _watchStats() {
    log('📊 Controller: Starting real-time stats watcher...');
    isLoadingStats.value = true;

    _statsSubscription = _service.watchStats().listen(
      (newStats) {
        stats.value = newStats;
        isLoadingStats.value = false;
        log('📊 Stats updated: $newStats');
      },
      onError: (e) {
        log('❌ Stats stream error: $e');
        isLoadingStats.value = false;
      },
    );
  }

  // ==================== TAB MANAGEMENT ====================
  void changeTab(int index) {
    if (index < 0 || index >= tabs.length) {
      log('⚠️ Invalid tab index: $index');
      return;
    }

    log('📑 Changing tab from ${currentTabIndex.value} to $index');
    currentTabIndex.value = index;
  }

  Future<void> refreshCurrentTab() async {
    log('🔄 Refreshing current tab (${getCurrentTitle()})...');

    switch (currentTabIndex.value) {
      case 0:
        await userController.fetchUsers();
        break;
      case 1:
        await menuController.refreshMenus();
        break;
      case 2:
        await categoryController.refreshCategories();
        break;
      case 3:
        // Tables use Stream-based architecture, just trigger sync
        await tableController.syncNow();
        break;
    }

    log('✅ Tab refresh completed');
  }

  // ==================== GETTERS ====================
  int getCurrentCount() {
    switch (currentTabIndex.value) {
      case 0:
        return stats.value.totalUsers;
      case 1:
        return stats.value.totalMenus;
      case 2:
        return stats.value.totalCategories;
      case 3:
        return stats.value.totalTables;
      default:
        return 0;
    }
  }

  String getCurrentTitle() {
    if (tabs.isEmpty) return 'Admin Control';
    return tabs[currentTabIndex.value].title;
  }

  String getCurrentIcon() {
    if (tabs.isEmpty) return 'dashboard';
    return tabs[currentTabIndex.value].icon;
  }

  String getCurrentRoute() {
    if (tabs.isEmpty) return '';
    return tabs[currentTabIndex.value].route;
  }

  // ==================== MANUAL REFRESH ====================
  Future<void> manualRefresh() async {
    if (!isOnline.value) {
      // Even offline, we can still refresh the current tab's local data
      snackbar.showInfoSnackbar('📴 Offline - Showing local data');
      await refreshCurrentTab();
      return;
    }

    snackbar.showInfoSnackbar('Refreshing data...');
    await _refreshAllData();
    snackbar.showSuccessSnackbar('Data refreshed successfully');
  }

  @override
  void onClose() {
    log('🔴 Disposing AdminManageControlController...');
    _connectivitySubscription?.cancel();
    _statsSubscription?.cancel();
    super.onClose();
  }
}
