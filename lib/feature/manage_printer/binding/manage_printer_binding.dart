import 'package:get/get.dart';
import '../controllers/manage_printer_controller.dart';

class ManagePrinterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagePrinterController>(() => ManagePrinterController());
  }
}
