import 'package:chiroku_cafe/feature/cashier/cashier_checkout/controllers/cashier_checkout_controller.dart';
import 'package:get/get.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
