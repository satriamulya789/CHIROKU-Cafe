import 'package:get/get.dart';
import 'package:chiroku_cafe/feature/on_board/controller/on_board_controller.dart';

class OnBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardController>(() => OnBoardController());
  }
}
