import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/binding/admin_bottom_bar_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/views/admin_bottom_bar_page.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/binding/admin_edit_category_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_category/views/admin_edit_category_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/binding/admin_edit_menu_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/views/admin_edit_menu_form_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/views/admin_edit_menu_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/binding/admin_edit_user_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_table/views/admin_edit_table_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/binding/admin_edit_user_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_user/views/admin_edit_user_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/binding/admin_manage_controll_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/views/admin_manage_control_view.dart';

import 'package:chiroku_cafe/feature/auth/complete_profile/binding/complete_profile_binding.dart';
import 'package:chiroku_cafe/feature/auth/complete_profile/views/complete_profile_page.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/binding/forgot_password_binding.dart';
import 'package:chiroku_cafe/feature/auth/forgot_password/views/forgot_password_page.dart';
import 'package:chiroku_cafe/feature/auth/on_board/on_board.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/binding/reset_password_binding.dart';
import 'package:chiroku_cafe/feature/auth/reset_password/views/reset_password_page.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/binding/sign_in_binding.dart';
import 'package:chiroku_cafe/feature/auth/sign_in/view/sign_in_page.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/binding/sign_up_binding.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/views/sign_up_page.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_bottom_bar/binding/cashier_bottom_bar_binding.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_bottom_bar/view/cashier_bottom_bar_page.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/auth/on_board/binding/on_board_binding.dart';

class Pages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboard,
      page: () => const OnBoardPages(),
      binding: OnBoardBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpPage(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileView(),
      binding: CompleteProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.bottomBarAdmin,
      page: () => const BottomBar(),
      binding: AdminBottomBarBinding(),
    ),
    GetPage(
      name: AppRoutes.bottomBarCashier,
      page: () => const CashierBottomBarView(),
      binding: CashierBottomBarBinding(),
    ),
    
    // Admin Manage Control Routes
    GetPage(
      name: AppRoutes.adminManageControl,
      page: () => const AdminManageControlView(),
      binding: AdminManageControlBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditUser,
      page: () => const AdminEditUserView(),
      binding: AdminEditUserBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditMenu,
      page: () => const AdminEditMenuView(),
      binding: AdminEditMenuBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditCategory,
      page: () => const AdminEditCategoryView(),
      binding: AdminEditCategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditTable,
      page: () => const AdminEditTableView(),
      binding: AdminEditTableBinding(),
    ),
    
    // Admin Menu Form Routes
    GetPage(
      name: AppRoutes.adminAddMenu,
      page: () => const AdminMenuFormPage(isEdit: false),
      binding: AdminEditMenuBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditMenuForm,
      page: () {
        final menuId = Get.arguments as int?;
        return AdminMenuFormPage(
          menuId: menuId,
          isEdit: true,
        );
      },
      binding: AdminEditMenuBinding(),
    ),
  ];
}