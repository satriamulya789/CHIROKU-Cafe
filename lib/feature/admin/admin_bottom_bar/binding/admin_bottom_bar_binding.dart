import 'package:chiroku_cafe/core/databases/database_helper.dart';
import 'package:chiroku_cafe/core/network/network_info.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/controllers/admin_bottom_bar_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/controllers/admin_edit_category_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/data_sources/categories_local_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/data_sources/categories_remote_data_source.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/repositories/admin_edit_category_repositories.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/services/admin_edit_category_sync_service.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/controllers/admin_edit_menu_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/controllers/admin_edit_table_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/controllers/admin_edit_user_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/controllers/admin_setting_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBottomBarBinding extends Bindings {
  @override
  void dependencies() {
    // Bottom Bar Controller
    Get.lazyPut<BottomBarController>(() => BottomBarController());

    // Settings Controller (akan otomatis di-load ketika tab Settings dibuka)
    Get.lazyPut<AdminSettingController>(() => AdminSettingController());
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
    Get.lazyPut<AdminManageControlController>(
      () => AdminManageControlController(),
      fenix: true,
    );

    // Sub controllers for AdminManageControlView
    Get.lazyPut<AdminEditUserController>(
      () => AdminEditUserController(),
      fenix: true,
    );
    Get.lazyPut<AdminEditMenuController>(
      () => AdminEditMenuController(),
      fenix: true,
    );

    // Category dependencies
    final database = Get.find<DatabaseHelper>().database;
    final networkInfo = Get.find<NetworkInfo>();
    final supabase = Supabase.instance.client;

    // Create data sources
    final categoriesLocalDataSource = CategoriesLocalDataSource(database);
    final categoriesRemoteDataSource = CategoriesRemoteDataSource(supabase);

    // Create repository with data sources
    final categoryRepository = CategoryRepositories(
      localDataSource: categoriesLocalDataSource,
      remoteDataSource: categoriesRemoteDataSource,
      networkInfo: networkInfo,
    );

    Get.lazyPut<CategorySyncService>(
      () => CategorySyncService(database, networkInfo, categoryRepository),
      fenix: true,
    );

    Get.lazyPut<CategoryService>(
      () => CategoryService(categoryRepository),
      fenix: true,
    );

    Get.lazyPut<AdminEditCategoryController>(
      () => AdminEditCategoryController(Get.find<CategoryService>()),
      fenix: true,
    );
    Get.lazyPut<AdminEditTableController>(
      () => AdminEditTableController(),
      fenix: true,
    );

    Get.lazyPut<ReportAdminController>(() => ReportAdminController());
  }
}
