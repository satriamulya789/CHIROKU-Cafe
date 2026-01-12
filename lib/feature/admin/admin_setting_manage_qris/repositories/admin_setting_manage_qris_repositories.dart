import 'dart:io';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/models/admin_setting_manage_qris_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/services/admin_setting_manage_qris_service.dart';

class PaymentSettingsRepository {
  final PaymentSettingsService _service = PaymentSettingsService();

  Future<PaymentSettingsModel> getPaymentSettings() async {
    try {
      final data = await _service.getPaymentSettings();
      return PaymentSettingsModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get payment settings: $e');
    }
  }

  Future<String?> uploadAndUpdateQris({
    required File imageFile,
    String? oldQrisUrl,
  }) async {
    try {
      final bucketExists = await _service.checkQrisBucketExists();
      if (!bucketExists) {
        throw Exception(
            'Storage bucket "qris" does not exist. Please create it in Supabase Storage.');
      }

      if (oldQrisUrl != null && oldQrisUrl.isNotEmpty) {
        await _service.deleteOldQrisImage(oldQrisUrl);
      }

      final String? newQrisUrl = await _service.uploadQrisImage(
        imageFile: imageFile,
      );

      if (newQrisUrl != null) {
        await _service.updateQrisUrl(
          qrisUrl: newQrisUrl,
        );
      }

      return newQrisUrl;
    } catch (e) {
      throw Exception('Failed to upload and update QRIS: $e');
    }
  }

  Future<void> removeQris() async {
    try {
      final settings = await getPaymentSettings();
      if (settings.qrisUrl != null) {
        await _service.deleteOldQrisImage(settings.qrisUrl);
        await _service.updateQrisUrl(qrisUrl: '');
      }
    } catch (e) {
      throw Exception('Failed to remove QRIS: $e');
    }
  }
}