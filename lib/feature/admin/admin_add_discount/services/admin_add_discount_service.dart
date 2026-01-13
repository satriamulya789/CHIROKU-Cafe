import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountService {
  final supabase = Supabase.instance.client;

  Future<void> addDiscount(DiscountModel discount) async {
    await supabase.from('discounts').insert(discount.toJson());
  }

  Future<List<DiscountModel>> getDiscounts() async {
    final response = await supabase.from('discounts').select();
    if (response == null) return [];
    return (response as List)
        .map((e) => DiscountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateDiscount(DiscountModel discount) async {
  await supabase
      .from('discounts')
      .update(discount.toJson())
      .eq('id', discount.id as Object);
}

Future<void> deleteDiscount(int id) async {
  await supabase.from('discounts').delete().eq('id', id);
}

}