import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_printer_controller.dart';
import '../models/manage_printer_model.dart';
import '../widgets/printer_device_card.dart';
import '../widgets/printer_status_banner.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class ManagePrinterView extends GetView<ManagePrinterController> {
  const ManagePrinterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brownDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Manage Printer',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isScanning.value
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.brownNormal,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.brownDark),
                    onPressed: controller.scanForPrinters,
                    tooltip: 'Refresh List',
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          const PrinterStatusBanner(),
          Expanded(
            child: Obx(() {
              if (controller.isScanning.value &&
                  controller.connectedDevices.isEmpty &&
                  controller.availableDevices.isEmpty) {
                return _buildScanningState();
              }

              if (controller.connectedDevices.isEmpty &&
                  controller.availableDevices.isEmpty) {
                return _buildEmptyState();
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (controller.connectedDevices.isNotEmpty) ...[
                    _buildSectionHeader('CONNECTED'),
                    ...controller.connectedDevices.map(
                      (d) => PrinterDeviceCard(printer: d),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (controller.availableDevices.isNotEmpty) ...[
                    _buildSectionHeader('AVAILABLE DEVICES'),
                    ...controller.availableDevices.map(
                      (d) => PrinterDeviceCard(printer: d),
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.connectionStatus.value ==
            PrinterConnectionStatus.connected) {
          return FloatingActionButton.extended(
            onPressed: controller.testPrint,
            backgroundColor: AppColors.brownNormal,
            elevation: 4,
            icon: controller.isPrinting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.print, color: AppColors.white, size: 20),
            label: Text(
              'Test Print',
              style: AppTypography.buttonSmall.copyWith(color: AppColors.white),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        title,
        style: AppTypography.overline.copyWith(
          color: AppColors.greyNormal,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
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
          const SizedBox(height: 24),
          Text(
            'Searching for devices...',
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                size: 48,
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Devices Found',
              style: AppTypography.h6.copyWith(color: AppColors.brownDark),
            ),
            const SizedBox(height: 12),
            Text(
              'Make sure your printer is turned on and Bluetooth is enabled on your phone.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.greyNormal,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.scanForPrinters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brownNormal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Scan Again',
                style: AppTypography.button.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
