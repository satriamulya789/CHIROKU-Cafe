import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/utils/enums/oder_enum.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> createOrder({
    required String cashierId,
    required String cashierName,
    int? tableId,
    String customerName = '',
    String note = '',
  }) async {
    final data = await _supabase
        .from(ApiConstant.ordersTable)
        .insert({
          'cashier_id': cashierId,
          'cashier_name': cashierName,
          'table_id': tableId,
          'customer_name': customerName,
          'note': note,
        })
        .select('id')
        .single();

    return data['id'];
  }

  Future<void> updateStatus(int orderId, OrderStatus status) async {
    await _supabase
        .from(ApiConstant.ordersTable)
        .update({'order_status': status.value})
        .eq('id', orderId);
  }

  Future<Map<String, dynamic>> getOrder(int orderId) async {
    return await _supabase
        .from(ApiConstant.ordersTable)
        .select()
        .eq('id', orderId)
        .single();
  }
}
