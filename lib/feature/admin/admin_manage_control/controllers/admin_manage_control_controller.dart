import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
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

  // Initialize all controllers
  late final AdminEditUserController userController;
  late final AdminEditMenuController menuController;
  late final AdminEditCategoryController categoryController;
  late final AdminEditTableController tableController;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenToConnectivity();
    _initializeControllers();
    _loadTabs();
    fetchStats();
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

  void _initializeControllers() {
    log('🎮 Initializing sub-controllers...');
    userController = Get.put(AdminEditUserController(), permanent: true);
    menuController = Get.put(AdminEditMenuController(), permanent: true);
    categoryController = Get.put(
      AdminEditCategoryController(),
      permanent: true,
    );
    tableController = Get.put(AdminEditTableController(), permanent: true);
    log('✅ All sub-controllers initialized');
  }

  void _loadTabs() {
    tabs.value = _service.getTabList();
    log('📑 Loaded ${tabs.length} tabs');
  }

  Future<void> _refreshAllData() async {
    await fetchStats(showLoading: false);
    await refreshCurrentTab();
  }

  // ==================== FETCH STATS ====================
  Future<void> fetchStats({bool showLoading = true}) async {
    try {
      if (showLoading) isLoadingStats.value = true;

      log('📊 Controller: Fetching stats...');
      stats.value = await _service.fetchStats();

      if (stats.value.totalUsers > 0 || stats.value.totalMenus > 0) {
        log('✅ Controller: Stats loaded - ${stats.value}');
      } else {
        log('⚠️ Controller: Empty stats returned');
      }
    } catch (e) {
      log('❌ Controller: Error fetching stats - $e');
      stats.value = AdminStatsModel.empty();

      // Don't show error snackbar if offline (already shown by connectivity listener)
      if (isOnline.value) {
        snackbar.showErrorSnackbar('Failed to fetch stats');
      }
    } finally {
      if (showLoading) isLoadingStats.value = false;
    }
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
        await menuController.fetchMenus();
        break;
      case 2:
        await categoryController.fetchCategories();
        break;
      case 3:
        await tableController.fetchTables();
        break;
    }

    await fetchStats(showLoading: false);
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
      snackbar.showInfoSnackbar('Cannot refresh while offline');
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
    super.onClose();
  }
}
