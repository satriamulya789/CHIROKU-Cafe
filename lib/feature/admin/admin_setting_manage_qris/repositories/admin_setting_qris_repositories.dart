import 'package:chiroku_cafe/feature/admin/admin_setting_manage_qris/models/admin_setting_qris_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSettingRepository {
  final supabase = Supabase.instance.client;

  /// Get QRIS settings
  Future<PaymentSettingModel?> getQrisSettings() async {
    try {
      final response = await supabase
          .from('payment_settings')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        // Create default setting if not exists
        await supabase.from('payment_settings').insert({
          'id': 1,
          'qris_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        return PaymentSettingModel(
          id: 1,
          qrisUrl: null,
          updatedAt: DateTime.now(),
        );
      }

      return PaymentSettingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get QRIS settings: $e');
    }
  }

  /// Update QRIS URL
  Future<void> updateQrisUrl(String qrisUrl) async {
    try {
      await supabase.from('payment_settings').upsert({
        'id': 1,
        'qris_url': qrisUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update QRIS URL: $e');
    }
  }

  /// Delete QRIS URL
  Future<void> deleteQrisUrl() async {
    try {
      await supabase.from('payment_settings').update({
        'qris_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', 1);
    } catch (e) {
      throw Exception('Failed to delete QRIS URL: $e');
    }
  }
}