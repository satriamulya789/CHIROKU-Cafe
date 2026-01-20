import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_printer_controller.dart';
import '../models/manage_printer_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class PrinterStatusBanner extends GetView<ManagePrinterController> {
  const PrinterStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.connectionStatus.value;
      final printer = controller.selectedPrinter.value;

      Color bgColor;
      Color textColor;
      String message;
      IconData icon;

      switch (status) {
        case PrinterConnectionStatus.connected:
          bgColor = AppColors.successLight;
          textColor = AppColors.successNormal;
          message = 'Connected to ${printer?.name ?? 'Printer'}';
          icon = Icons.check_circle_outline;
          break;
        case PrinterConnectionStatus.connecting:
          bgColor = AppColors.brownLight;
          textColor = AppColors.brownNormal;
          message = 'Connecting to ${printer?.name ?? 'printer'}...';
          icon = Icons.sync;
          break;
        case PrinterConnectionStatus.error:
          bgColor = AppColors.alertLight;
          textColor = AppColors.alertNormal;
          message = 'Connection Failed';
          icon = Icons.error_outline;
          break;
        case PrinterConnectionStatus.disconnected:
          bgColor = AppColors.greyLight;
          textColor = AppColors.greyNormal;
          message = 'No Printer Connected';
          icon = Icons.print_disabled_outlined;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmallBold.copyWith(color: textColor),
              ),
            ),
            if (status == PrinterConnectionStatus.connected)
              GestureDetector(
                onTap: controller.disconnectPrinter,
                child: Text(
                  'Disconnect',
                  style: AppTypography.captionSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
