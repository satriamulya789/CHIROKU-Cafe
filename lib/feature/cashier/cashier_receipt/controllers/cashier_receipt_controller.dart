import 'dart:developer';
import 'package:chiroku_cafe/feature/cashier/cashier_receipt/models/cashier_receipt_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_receipt/services/cashier_receipt_service.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ReceiptController extends GetxController {
  final ReceiptService _service = ReceiptService();
  final CustomSnackbar _snackbar = CustomSnackbar();

  final Rx<ReceiptModel?> receipt = Rx<ReceiptModel?>(null);
  final RxBool isProcessing = false.obs;
  final RxBool isPrinting = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReceiptData();
  }

  /// Load receipt data from arguments
  void _loadReceiptData() {
    try {
      final orderData = Get.arguments as Map<String, dynamic>?;

      if (orderData == null) {
        log('❌ No order data provided');
        _snackbar.showErrorSnackbar('Order data not found');
        return;
      }

      receipt.value = ReceiptModel.fromOrderData(orderData);
      log('✅ Receipt data loaded: Order #${receipt.value?.orderNumber}');
    } catch (e) {
      log('❌ Error loading receipt data: $e');
      _snackbar.showErrorSnackbar('Failed to load receipt data');
    }
  }

  /// Show print options (will be handled by view)
  Future<String?> showPrintOptions() async {
    // This will be called from view which will show the dialog
    // and return the result
    return null;
  }

  /// Print receipt
  Future<void> printReceipt() async {
    if (receipt.value == null) {
      _snackbar.showErrorSnackbar('Receipt data not available');
      return;
    }

    try {
      isPrinting.value = true;
      await _service.printReceipt(receipt.value!);
      _snackbar.showSuccessSnackbar('Receipt printed successfully');
    } catch (e) {
      log('❌ Error printing receipt: $e');
      _snackbar.showErrorSnackbar('Failed to print receipt');
    } finally {
      isPrinting.value = false;
    }
  }

  /// Save receipt as PDF
  Future<void> saveReceiptPDF() async {
    if (receipt.value == null) {
      _snackbar.showErrorSnackbar('Data struk tidak tersedia');
      return;
    }

    try {
      isSaving.value = true;
      await _service.saveReceiptPDF(receipt.value!);
      _snackbar.showSuccessSnackbar('Receipt saved successfully');
    } catch (e) {
      log('❌ Error saving receipt: $e');
      _snackbar.showErrorSnackbar('Failed to save receipt');
    } finally {
      isSaving.value = false;
    }
  }

  /// Complete order and return to menu
  Future<void> completeOrder() async {
    try {
      isProcessing.value = true;
      final status = receipt.value?.status;
      if (status == 'pending') {
        _snackbar.showSuccessSnackbar('Order disimpan sebagai pending');
      } else {
        _snackbar.showSuccessSnackbar('Transaksi selesai');
      }

      // Wait a bit for the snackbar to show
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate back to cashier bottom bar (which shows order page by default)
      Get.offAllNamed('/bottom-bar-cashier');

      log('✅ Order process completed');
    } catch (e) {
      log('❌ Error completing order: $e');
      _snackbar.showErrorSnackbar('Failed to complete transaction');
    } finally {
      isProcessing.value = false;
    }
  }
}
