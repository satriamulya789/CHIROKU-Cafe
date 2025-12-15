import 'package:chiroku_cafe/config/routes/route.dart';
import 'package:chiroku_cafe/feature/on_board/on_board.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/on_board/binding/on_board_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.onboard,
      page: () => const OnBoardPages(),
      binding: OnBoardBinding(),
    ),
  ];
}
