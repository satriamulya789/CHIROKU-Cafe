import 'package:chiroku_cafe/feature/admin/admin_add_discount/controllers/admin_add_discount_controller.dart';
import 'package:get/get.dart';

class DiscountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscountController>(() => DiscountController());
  }
}