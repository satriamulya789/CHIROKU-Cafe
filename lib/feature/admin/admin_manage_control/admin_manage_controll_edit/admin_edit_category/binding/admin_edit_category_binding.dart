import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/repositories/admin_edit_category_repositories.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_sync_service.dart';
import 'package:get/get.dart';

class AdminEditCategoryBinding extends Bindings {
  @override
  void dependencies() {
    final database = Get.find<DatabaseHelper>().database;
    final networkInfo = Get.find<NetworkInfo>();
    final repository = CategoryRepositories();

    // Sync Service
    Get.lazyPut<CategorySyncService>(
      () => CategorySyncService(database, networkInfo, repository),
    );

    // Category Service
    Get.lazyPut<CategoryService>(
      () => CategoryService(
        database,
        networkInfo,
        Get.find<CategorySyncService>(),
      ),
    );

    // Controller
    Get.lazyPut<AdminEditCategoryController>(
      () => AdminEditCategoryController(Get.find<CategoryService>()),
    );
  }
}
