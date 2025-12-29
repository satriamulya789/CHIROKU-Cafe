import 'package:chiroku_cafe/config/routes/route.dart';
import 'package:chiroku_cafe/feature/on_board/on_board.dart';
import 'package:chiroku_cafe/feature/sign_in/binding/sign_in_binding.dart';
import 'package:chiroku_cafe/feature/sign_in/sign_in.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/on_board/binding/on_board_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboard,
      page: () => const OnBoardPages(),
      binding: OnBoardBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),
  ];
}
