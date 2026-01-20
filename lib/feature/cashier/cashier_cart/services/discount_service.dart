import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountService {
  final _supabase = Supabase.instance.client;

  /// Get all active discounts
  Future<List<Map<String, dynamic>>> getActiveDiscounts() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('discounts')
          .select()
          .eq('is_active', true)
          .or('start_date.is.null,start_date.lte.$now')
          .or('end_date.is.null,end_date.gte.$now')
          .order('value', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching discounts: $e');
      rethrow;
    }
  }

  /// Get discount by ID
  Future<Map<String, dynamic>?> getDiscountById(int id) async {
    try {
      final response = await _supabase
          .from('discounts')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching discount: $e');
      return null;
    }
  }
}
