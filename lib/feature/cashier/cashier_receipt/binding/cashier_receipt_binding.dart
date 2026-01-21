import 'package:chiroku_cafe/feature/cashier/cashier_receipt/controllers/cashier_receipt_controller.dart';
import 'package:get/get.dart';

class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiptController>(() => ReceiptController());
  }
}
