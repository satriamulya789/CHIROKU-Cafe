import 'package:chiroku_cafe/feature/cashier/cashier_edit_profile/controllers/cashier_edit_profile_controller.dart';
import 'package:get/get.dart';

class CashierEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierEditProfileController>(
      () => CashierEditProfileController(),
    );
  }
}
