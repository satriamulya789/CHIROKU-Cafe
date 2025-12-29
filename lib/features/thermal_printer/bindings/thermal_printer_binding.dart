import 'package:get/get.dart';
import '../controllers/thermal_printer_controller.dart';

class ThermalPrinterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThermalPrinterController>(
      () => ThermalPrinterController(),
    );
  }
}
