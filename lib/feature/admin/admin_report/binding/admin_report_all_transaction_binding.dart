import 'package:chiroku_cafe/feature/admin/admin_report/controllers/admin_report_all_transaction_controller.dart';
import 'package:get/get.dart';

class AllTransactionsBinding extends Bindings {
  final DateTime startDate;
  final DateTime endDate;
  final String? cashierId;

  AllTransactionsBinding({
    required this.startDate,
    required this.endDate,
    this.cashierId,
  });

  @override
  void dependencies() {
    Get.lazyPut<AllTransactionsController>(() => AllTransactionsController(
      startDate: startDate,
      endDate: endDate,
      cashierId: cashierId,
    ));
  }
}