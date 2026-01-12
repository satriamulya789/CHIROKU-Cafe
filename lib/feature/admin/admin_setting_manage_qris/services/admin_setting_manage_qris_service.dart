import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getPaymentSettings() async {
    try {
      final response = await _supabase
          .from('payment_settings')
          .select()
          .eq('id', 1)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get payment settings: $e');
    }
  }

  Future<String?> uploadQrisImage({
    required File imageFile,
  }) async {
    try {
      final String fileName = 'qris-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = fileName;

      final bytes = await imageFile.readAsBytes();

      await _supabase.storage.from('qris').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final String publicUrl = _supabase.storage.from('qris').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload QRIS image: $e');
    }
  }

  Future<void> updateQrisUrl({
    required String qrisUrl,
  }) async {
    try {
      await _supabase.from('payment_settings').upsert({
        'id': 1,
        'qris_url': qrisUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update QRIS URL: $e');
    }
  }

  Future<void> deleteOldQrisImage(String? oldQrisUrl) async {
    if (oldQrisUrl == null || oldQrisUrl.isEmpty) return;

    try {
      final Uri uri = Uri.parse(oldQrisUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments[pathSegments.length - 1];

        final files = await _supabase.storage.from('qris').list();

        final fileExists = files.any((file) => file.name == fileName);

        if (fileExists) {
          await _supabase.storage.from('qris').remove([fileName]);
        }
      }
    } catch (e) {
      print('Failed to delete old QRIS image: $e');
    }
  }

  Future<bool> checkQrisBucketExists() async {
    try {
      await _supabase.storage.from('qris').list();
      return true;
    } catch (e) {
      return false;
    }
  }
}