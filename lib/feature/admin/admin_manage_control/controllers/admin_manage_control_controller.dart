
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controlle.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/models/admin_manage_controll_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/services/admin_manage_controll_service.dart';
import 'package:get/get.dart';

class AdminManageControlController extends GetxController {
  final AdminManageControlService _service = AdminManageControlService();

  final currentTabIndex = 0.obs;
  final isLoadingStats = false.obs;
  final stats = AdminStatsModel.empty().obs;
  final tabs = <AdminTabModel>[].obs;

  // Initialize all controllers
  late final AdminEditUserController userController;
  late final AdminEditMenuController menuController;
  late final AdminEditCategoryController categoryController;
  late final AdminEditTableController tableController;


  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadTabs();
    fetchStats();
  }

  void _initializeControllers() {
    userController = Get.put(AdminEditUserController(), permanent: true);
    menuController = Get.put(AdminEditMenuController(), permanent: true);
    categoryController = Get.put(AdminEditCategoryController(), permanent: true);
    tableController = Get.put(AdminEditTableController(), permanent: true);
  }

  void _loadTabs() {
    tabs.value = _service.getTabList();
  }

  Future<void> fetchStats() async {
    try {
      isLoadingStats.value = true;
      stats.value = await _service.fetchStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch stats: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingStats.value = false;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void refreshCurrentTab() {
    switch (currentTabIndex.value) {
      case 0:
        userController.fetchUsers();
        break;
      case 1:
        menuController.fetchMenus();
        break;
      case 2:
        categoryController.fetchCategories();
        break;
      case 3:
        tableController.fetchTables();
        break;
    }
    fetchStats();
  }

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

  @override
  void onClose() {
    // Don't delete controllers as they are permanent
    super.onClose();
  }
}