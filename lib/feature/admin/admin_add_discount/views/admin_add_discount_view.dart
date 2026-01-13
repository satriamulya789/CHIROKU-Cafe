import 'package:chiroku_cafe/feature/admin/admin_add_discount/controllers/admin_add_discount_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/widgets/admin_add_discount_dialog_widget.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/widgets/admin_add_discount_list_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDiscountView extends GetView<DiscountController> {
  const AddDiscountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        title: Text('Discount List', style: AppTypography.h4.copyWith(color: AppColors.brownDarker)),
        backgroundColor: AppColors.brownLight,
        elevation: 0,
        foregroundColor: AppColors.brownDarker,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDiscountDialog(context),
          ),
        ],
      ),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: DiscountListWidget(
          discounts: controller.discounts.toList(),
          onEdit: (discount) => _showAddDiscountDialog(context, discount: discount),
          onDelete: (id) => controller.deleteDiscount(id),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brownNormal,
        onPressed: () => _showAddDiscountDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDiscountDialog(BuildContext context, {DiscountModel? discount}) {
    final controller = Get.find<DiscountController>();
    if (discount != null) {
      controller.nameController.text = discount.name;
      controller.valueController.text = discount.value.toString();
      controller.type.value = discount.type;
      controller.isActive.value = discount.isActive;
      controller.startDate.value = discount.startDate;
      controller.endDate.value = discount.endDate;
    } else {
      controller.clearForm();
    }

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.brownLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: DiscountDialogWidget(controller: controller, discount: discount),
          ),
        ),
      ),
    );
  }
}