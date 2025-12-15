import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderItemRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addItem({
    required int orderId,
    required int menuId,
    required int qty,
    required double price,
    String note = '',
  }) async {
    await _supabase.from(ApiConstant.orderItemsTable).insert({
      'order_id': orderId,
      'menu_id': menuId,
      'qty': qty,
      'price': price,
      'total': qty * price,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getItems(int orderId) async {
    return await _supabase
        .from(ApiConstant.orderItemsTable)
        .select()
        .eq('order_id', orderId);
  }
}
