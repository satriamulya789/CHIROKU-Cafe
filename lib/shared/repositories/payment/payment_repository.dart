import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/utils/enums/enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class PaymentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> pay({
    required int orderId,
    required PaymentMethod method,
    required double amount,
  }) async {
    await _supabase.from(ApiConstant.paymentsTable).insert({
      'order_id': orderId,
      'payment_method': method.value,
      'amount': amount,
    });

    await _supabase
        .from(ApiConstant.ordersTable)
        .update({'order_status': OrderStatus.paid.value})
        .eq('id', orderId);
  }
}
