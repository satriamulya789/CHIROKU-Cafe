import 'package:chiroku_cafe/configs/pages/admin/bottom_bar.dart';
import 'package:chiroku_cafe/features/cashier/cashier.dart';
import 'package:chiroku_cafe/features/cashier/pages/all_transactions_page.dart';
import 'package:chiroku_cafe/configs/pages/settings_pages.dart';
import 'package:chiroku_cafe/features/forgot_passoword/binding/password_binding.dart';
import 'package:chiroku_cafe/features/forgot_passoword/binding/reset_password.dart';
import 'package:chiroku_cafe/features/on_board/onboarding.dart';
import 'package:chiroku_cafe/features/sign_in/binding/login_binding.dart';
import 'package:chiroku_cafe/features/sign_in/login_page.dart';
import 'package:chiroku_cafe/features/sign_up/binding/singup_binding.dart';
import 'package:chiroku_cafe/features/sign_up/register_page.dart';
import 'package:chiroku_cafe/features/forgot_passoword/forgot_passowrd.dart';
import 'package:chiroku_cafe/features/thermal_printer/thermal_printer.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/configs/pages/admin/menu_controller.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeadmin = '/homeadmin';
  static const String homecashier = '/homecashier';
  static const String onboarding = '/onboarding';
  static const String menuControl = '/menu-control';
  static const String settings = '/settings';

  // Auth routes
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Cashier routes
  static const String cashierOrder = '/cashier/order';
  static const String cashierCart = '/cashier/cart';
  static const String cashierOrders = '/cashier/orders';
  static const String cashierCheckout = '/cashier/checkout';
  static const String cashierReport = '/cashier/report';
  static const String allTransactions = '/all-transactions';
  static const String tableManagement = '/cashier/tables';

  // Printer routes
  static const String printerSettings = '/printer-settings';

  static const String initialRoute = onboarding;

  // Route pages
  static final List<GetPage> pages = [
    // Onboarding
    GetPage(
      name: onboarding,
      page: () => Onboarding(),
      transition: Transition.fadeIn,
    ),

    // Auth Routes
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: resetPassword,
      page: () =>  ResetPasswordPage(email: '',),
      binding: ResetPasswordBinding(),
      transition: Transition.rightToLeft,
    ),

    // Admin Routes
    GetPage(
      name: homeadmin,
      page: () => const BottomBar(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: menuControl,
      page: () => const MenuControlPage(),
      transition: Transition.rightToLeft,
    ),

    // Cashier Routes
    GetPage(
      name: homecashier,
      page: () => const BottomBarCashier(),
      binding: CashierDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: cashierOrder,
      page: () => const OrderPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cashierCart,
      page: () => const CartPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cashierOrders,
      page: () => const OrderManagementPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cashierCheckout,
      page: () => const CheckoutPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cashierReport,
      page: () => const ReportPageS(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: allTransactions,
      page: () => const AllTransactionsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: tableManagement,
      page: () => const TableManagementPage(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),

    // Printer Settings
    GetPage(
      name: printerSettings,
      page: () => const PrinterSettingsPage(),
      binding: ThermalPrinterBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}