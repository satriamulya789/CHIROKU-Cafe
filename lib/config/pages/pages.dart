import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/binding/admin_add_discout_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/views/admin_add_discount_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/binding/admin_bottom_bar_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/views/admin_bottom_bar_page.dart';
import 'package:chiroku_cafe/feature/admin/admin_edit_profile/binding/admin_edit_profile_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_edit_profile/views/admin_edit_profile_view.dart';
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
import 'package:chiroku_cafe/feature/admin/admin_report/binding/admin_report_all_transaction_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/binding/admin_report_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_all_transaction_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/views/admin_report_all_transaction_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_report/views/admin_report_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting/binding/admin_setting_binding.dart' show AdminSettingBinding;
import 'package:chiroku_cafe/feature/admin/admin_setting/views/admin_setting_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_printer/binding/thermal_printer_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_printer/views/thermal_printer_view.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/binding/admin_manage_qris_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/views/admin_manage_qris_view.dart';
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
import 'package:chiroku_cafe/feature/cashier/cashier_order/binding/cashier_order_binding.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/views/cashier_order_view.dart';
import 'package:chiroku_cafe/feature/push_notification/binding/push_notification_binding.dart';
import 'package:chiroku_cafe/feature/push_notification/views/push_notification_view.dart';
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

    // Edit Profile Route
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
  name: AppRoutes.paymentSettings,
  page: () => const PaymentSettingsView(),
  binding: PaymentSettingsBinding(),
),
    
    // Thermal Printer Route
    GetPage(
      name: AppRoutes.thermalPrinterSettings,
      page: () => const ThermalPrinterSettingsView(),
      binding: ThermalPrinterBinding(),
    ),
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingView(),
      binding: AdminSettingBinding(),
    ),
    GetPage(
  name: AppRoutes.adminReport,
  page: () => const ReportAdminView(),
  binding: ReportAdminBinding(),
),

    //
    GetPage(
      name: AppRoutes.pushNotificationSettings,
      page: () => const PushNotificationView(),
      binding: PushNotificationBinding(),
    ),  

   //all transactions
   GetPage(
  name: AppRoutes.adminAllTransactions,
  page: () => const AllTransactionsView(), // <-- tanpa parameter
  binding: BindingsBuilder(() {
    final args = Get.arguments as Map<String, dynamic>;
    Get.lazyPut<AllTransactionsController>(() => AllTransactionsController(
      startDate: args['startDate'] as DateTime,
      endDate: args['endDate'] as DateTime,
      cashierId: args['cashierId'] as String?,
    ));
  }),
),

//add discount
GetPage(
  name: AppRoutes.adminAddDiscount,
  page: () => const AddDiscountView(),
  binding: DiscountBinding(),
),



//cashier    
GetPage(
      name: AppRoutes.cashierOrder,
      page: () => OrderPage(),
      binding: OrderBinding(),
    ),
   
  ];
}