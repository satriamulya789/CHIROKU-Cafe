import 'package:chiroku_cafe/feature/admin/admin_add_discount/controllers/admin_add_discount_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/models/admin_add_discount_model.dart';
import 'package:chiroku_cafe/feature/admin/admin_add_discount/widgets/admin_add_discount_date_range_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountDialogWidget extends StatelessWidget {
  final DiscountController controller;
  final DiscountModel? discount;
  const DiscountDialogWidget({
    super.key,
    required this.controller,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(discount == null ? 'Add Discount' : 'Edit Discount', style: AppTypography.h5),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Discount Name',
              labelStyle: AppTypography.bodyMedium,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Discount Value',
                    labelStyle: AppTypography.bodyMedium,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.type.value,
                  items: const [
                    DropdownMenuItem(value: 'fixed', child: Text('Nominal')),
                    DropdownMenuItem(value: 'percent', child: Text('Percent')),
                  ],
                  onChanged: (val) => controller.type.value = val ?? 'fixed',
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: AppTypography.bodyMedium,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text('Active', style: AppTypography.bodyMedium),
            value: controller.isActive.value,
            onChanged: (val) => controller.isActive.value = val,
            activeColor: AppColors.successNormal,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DateRangeButtonWidget(
                  label: 'Start',
                  date: controller.startDate.value,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.startDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.brownNormal,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: AppColors.brownDarker,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.startDate.value = picked;
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DateRangeButtonWidget(
                  label: 'End',
                  date: controller.endDate.value,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.endDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.brownNormal,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: AppColors.brownDarker,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.endDate.value = picked;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (discount == null) {
                        controller.addDiscount();
                      } else {
                        controller.updateDiscount(
                          discount!.copyWith(
                            name: controller.nameController.text,
                            type: controller.type.value,
                            value: double.tryParse(controller.valueController.text) ?? 0,
                            isActive: controller.isActive.value,
                            startDate: controller.startDate.value,
                            endDate: controller.endDate.value,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successNormal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : Text(
                      discount == null ? 'Save Discount' : 'Update Discount',
                      style: AppTypography.button.copyWith(color: AppColors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}