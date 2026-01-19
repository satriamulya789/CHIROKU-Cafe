import 'package:chiroku_cafe/feature/setting_manage_printer/controllers/thermal_printer_controller.dart';
import 'package:chiroku_cafe/feature/setting_manage_printer/models/thermal_printer_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionStatusCardWidget extends GetView<ThermalPrinterController> {
  const ConnectionStatusCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.connectionStatus.value;
      final printer = controller.selectedPrinter.value;

      Color statusColor;
      IconData statusIcon;
      String statusText;

      switch (status) {
        case PrinterConnectionStatus.connected:
          statusColor = AppColors.successNormal;
          statusIcon = Icons.check_circle;
          statusText = 'Connected';
          break;
        case PrinterConnectionStatus.connecting:
          statusColor = AppColors.warningNormal;
          statusIcon = Icons.sync;
          statusText = 'Connecting...';
          break;
        case PrinterConnectionStatus.error:
          statusColor = AppColors.alertNormal;
          statusIcon = Icons.error;
          statusText = 'Error';
          break;
        default:
          statusColor = AppColors.brownNormal;
          statusIcon = Icons.bluetooth_disabled;
          statusText = 'Not Connected';
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: AppTypography.h6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  if (printer != null)
                    Text(
                      printer.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brownDark,
                      ),
                    ),
                ],
              ),
            ),
            if (status == PrinterConnectionStatus.connected)
              TextButton(
                onPressed: controller.disconnectPrinter,
                child: Text(
                  'Disconnect',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.alertNormal,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}