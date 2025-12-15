import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMenus() async {
    return await _supabase
        .from(ApiConstant.menusTable)
        .select()
        .eq('is_available', true)
        .order('name');
  }
}
