import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_printer_controller.dart';
import '../models/manage_printer_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class PrinterDeviceCard extends GetView<ManagePrinterController> {
  final BluetoothPrinterModel printer;

  const PrinterDeviceCard({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected =
          controller.selectedPrinter.value?.macAddress == printer.macAddress;
      final isConnected =
          controller.connectionStatus.value ==
              PrinterConnectionStatus.connected &&
          isSelected;
      final isConnecting =
          controller.connectionStatus.value ==
              PrinterConnectionStatus.connecting &&
          isSelected;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isConnected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isConnected ? AppColors.successNormal : AppColors.greyLight,
            width: isConnected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isConnecting
              ? null
              : () => controller.connectToPrinter(printer),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppColors.successNormal.withOpacity(0.1)
                        : AppColors.brownNormal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bluetooth,
                    color: isConnected
                        ? AppColors.successNormal
                        : AppColors.brownNormal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        printer.name.isEmpty ? "Unknown Device" : printer.name,
                        style: AppTypography.bodyMediumBold.copyWith(
                          color: AppColors.brownDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        printer.macAddress,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.greyNormal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Section
                if (isConnecting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.brownNormal,
                      ),
                    ),
                  )
                else if (isConnected)
                  IconButton(
                    icon: const Icon(
                      Icons.link_off,
                      color: AppColors.alertNormal,
                    ),
                    onPressed: controller.disconnectPrinter,
                    tooltip: 'Disconnect',
                  )
                else
                  const Icon(Icons.chevron_right, color: AppColors.greyNormal),
              ],
            ),
          ),
        ),
      );
    });
  }
}
