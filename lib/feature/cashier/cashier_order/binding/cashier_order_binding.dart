import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:get/get.dart';

/// Binding for Order Page
/// Handles dependency injection for OrderController
class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put OrderController - will be created when first needed
    Get.lazyPut<OrderController>(
      () => OrderController(),
      fenix: true, // Keep controller alive even after page disposal
    );
  }
}
