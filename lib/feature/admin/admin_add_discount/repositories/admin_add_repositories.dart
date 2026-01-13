import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/services/admin_add_discount_service.dart';

class DiscountRepository {
  final DiscountService _service = DiscountService();

  Future<void> addDiscount(DiscountModel discount) async {
    await _service.addDiscount(discount);
  }

  Future<List<DiscountModel>> getDiscounts() async {
    return await _service.getDiscounts();
  }

  Future<void> updateDiscount(DiscountModel discount) async {
  await _service.updateDiscount(discount);
}

Future<void> deleteDiscount(int id) async {
  await _service.deleteDiscount(id);
}
}