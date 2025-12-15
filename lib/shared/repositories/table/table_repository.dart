import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class TableRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTables() async {
    return await _supabase
        .from(ApiConstant.tablesTable)
        .select()
        .order('id');
  }

  Future<void> updateStatus(int tableId, String status) async {
    await _supabase
        .from(ApiConstant.tablesTable)
        .update({'table_status': status})
        .eq('id', tableId);
  }
}
