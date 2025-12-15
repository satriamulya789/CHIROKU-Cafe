import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getDiscountByCode(String code) async {
    return await _supabase
        .from(ApiConstant.discountsTable)
        .select()
        .eq('code', code)
        .eq('is_active', true)
        .maybeSingle();
  }
}
