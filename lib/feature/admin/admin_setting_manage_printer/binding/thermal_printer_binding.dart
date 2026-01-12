import 'package:chiroku_cafe/feature/admin/admin_setting_manage_printer/controllers/thermal_printer_controller.dart';
import 'package:get/get.dart';

class ThermalPrinterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThermalPrinterController>(
      () => ThermalPrinterController(),
    );
  }
}