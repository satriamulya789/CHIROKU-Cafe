import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/repositories/admin_add_repositories.dart';
import 'package:chiroku_cafe/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountController extends GetxController {
  final discounts = <DiscountModel>[].obs;
  final DiscountRepository _repo = DiscountRepository();

  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final type = 'fixed'.obs;
  final isActive = true.obs;

  // changed to reactive Date values to use Obx consistently
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscounts();
  }

  Future<void> fetchDiscounts() async {
    try {
      final result = await _repo.getDiscounts();
      discounts.assignAll(result);
    } catch (e) {
      CustomSnackbar().showErrorSnackbar('Failed to fetch discounts');
    }
  }

  Future<void> addDiscount() async {
    if (nameController.text.isEmpty || valueController.text.isEmpty) {
      CustomSnackbar().showErrorSnackbar('Name and value must be filled');
      return;
    }
    isLoading.value = true;
    try {
      final discount = DiscountModel(
        name: nameController.text,
        type: type.value,
        value: double.parse(valueController.text),
        isActive: isActive.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      await _repo.addDiscount(discount);
      CustomSnackbar().showSuccessSnackbar('Discount added successfully');
      clearForm();
      Get.back();
      await fetchDiscounts();
    } catch (e) {
      CustomSnackbar().showErrorSnackbar('Failed to add discount');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDiscount(DiscountModel discount) async {
  isLoading.value = true;
  try {
    await _repo.updateDiscount(discount);
    CustomSnackbar().showSuccessSnackbar('Discount updated successfully');
    await fetchDiscounts();
    Get.back();
  } catch (e) {
    CustomSnackbar().showErrorSnackbar('Failed to update discount');
  } finally {
    isLoading.value = false;
  }
}

Future<void> deleteDiscount(int id) async {
  isLoading.value = true;
  try {
    await _repo.deleteDiscount(id);
    CustomSnackbar().showSuccessSnackbar('Discount deleted successfully');
    await fetchDiscounts();
  } catch (e) {
    CustomSnackbar().showErrorSnackbar('Failed to delete discount');
  } finally {
    isLoading.value = false;
  }
}


  void clearForm() {
    nameController.clear();
    valueController.clear();
    type.value = 'fixed';
    isActive.value = true;
    startDate.value = null;
    endDate.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    valueController.dispose();
    super.onClose();
  }
}