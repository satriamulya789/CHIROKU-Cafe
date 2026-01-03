import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/auth/on_board/on_board.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/binding/sign_up_binding.dart';
import 'package:chiroku_cafe/feature/auth/sign_up/views/sign_up_page.dart';
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
    // GetPage(
    //   name: AppRoutes.signIn,
    //   page: () => const SignInPage(),
    //   binding: SignInBinding(),
    // ),
  ];
}
