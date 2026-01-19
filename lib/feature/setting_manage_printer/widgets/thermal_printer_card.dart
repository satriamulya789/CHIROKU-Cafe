import 'package:chiroku_cafe/feature/setting_manage_printer/controllers/thermal_printer_controller.dart';
import 'package:chiroku_cafe/feature/setting_manage_printer/models/thermal_printer_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrinterCardWidget extends GetView<ThermalPrinterController> {
  final BluetoothPrinterModel printer;

  const PrinterCardWidget({
    super.key,
    required this.printer,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPrinter.value?.macAddress == printer.macAddress;
      final isConnected = controller.connectionStatus.value == PrinterConnectionStatus.connected && isSelected;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isConnected ? AppColors.successNormal : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.successNormal.withOpacity(0.1)
                  : AppColors.blueNormal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isConnected ? Icons.print : Icons.print_outlined,
              color: isConnected ? AppColors.successNormal : AppColors.blueNormal,
              size: 28,
            ),
          ),
          title: Text(
            printer.name,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                printer.macAddress,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brownNormal,
                ),
              ),
              if (isConnected)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successNormal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Connected',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.successNormal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          trailing: _buildTrailing(isConnected, isSelected),
        ),
      );
    });
  }

  Widget _buildTrailing(bool isConnected, bool isSelected) {
    if (controller.connectionStatus.value == PrinterConnectionStatus.connecting && isSelected) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
        ),
      );
    }

    if (isConnected) {
      return IconButton(
        icon: const Icon(Icons.close, color: AppColors.alertNormal),
        onPressed: controller.disconnectPrinter,
      );
    }

    return ElevatedButton(
      onPressed: () => controller.connectToPrinter(printer),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Connect',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}