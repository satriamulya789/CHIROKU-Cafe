import 'dart:developer';
import 'package:chiroku_cafe/feature/cashier/cashier_receipt/models/cashier_receipt_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_receipt/repositories/cashier_receipt_repositories.dart';

class ReceiptService {
  final ReceiptRepository _repository = ReceiptRepository();

  /// Generate PDF receipt
  Future<void> generatePDF(ReceiptModel receipt) async {
    try {
      await _repository.generateReceiptPDF(receipt);
      log('✅ PDF generated successfully');
    } catch (e) {
      log('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  /// Print receipt
  Future<void> printReceipt(ReceiptModel receipt) async {
    try {
      await _repository.printReceipt(receipt);
      log('✅ Receipt printed successfully');
    } catch (e) {
      log('❌ Error printing receipt: $e');
      rethrow;
    }
  }

  /// Save receipt as PDF
  Future<void> saveReceiptPDF(ReceiptModel receipt) async {
    try {
      await _repository.saveReceiptPDF(receipt);
      log('✅ Receipt saved successfully');
    } catch (e) {
      log('❌ Error saving receipt: $e');
      rethrow;
    }
  }
}
