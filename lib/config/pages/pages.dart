import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/binding/admin_bottom_bar_binding.dart';
import 'package:chiroku_cafe/feature/admin/admin_bottom_bar/views/admin_bottom_bar_page.dart';
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
      binding:
          CompleteProfileBinding(), // Uncomment if you have a binding for this page
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
  ];
}
