import 'package:chiroku_cafe/feature/setting_manage_printer/controllers/thermal_printer_controller.dart';
import 'package:chiroku_cafe/feature/setting_manage_printer/models/thermal_printer_model.dart';
import 'package:chiroku_cafe/feature/setting_manage_printer/widgets/thermal_printer_card.dart';
import 'package:chiroku_cafe/feature/setting_manage_printer/widgets/thermal_printer_connecttion_status_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThermalPrinterSettingsView extends GetView<ThermalPrinterController> {
  const ThermalPrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brownDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Printer Settings',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.isScanning.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.brownDark),
                  onPressed: controller.scanForPrinters,
                  tooltip: 'Scan Printers',
                )),
        ],
      ),
      body: Column(
        children: [
          const ConnectionStatusCardWidget(),
          Expanded(
            child: Obx(() {
              if (controller.isScanning.value && controller.availableDevices.isEmpty) {
                return _buildScanningState();
              }

              if (controller.availableDevices.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableDevices.length,
                itemBuilder: (context, index) {
                  final printer = controller.availableDevices[index];
                  return PrinterCardWidget(printer: printer);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.connectionStatus.value == PrinterConnectionStatus.connected) {
          return FloatingActionButton.extended(
            onPressed: controller.testPrint,
            backgroundColor: AppColors.brownNormal,
            icon: controller.isPrinting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Icon(Icons.print, color: AppColors.white),
            label: Text(
              'Test Print',
              style: AppTypography.button.copyWith(
                color: AppColors.white,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildScanningState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brownNormal),
          ),
          const SizedBox(height: 16),
          Text(
            'Scanning for printers...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_disabled,
            size: 64,
            color: AppColors.brownNormal.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No printers found',
            style: AppTypography.h6.copyWith(
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure the printer is paired\nin Bluetooth settings',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.brownNormal,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.scanForPrinters,
            icon: const Icon(Icons.search),
            label: Text(
              'Scan Printers',
              style: AppTypography.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownNormal,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}