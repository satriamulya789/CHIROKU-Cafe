import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OrderCategoryFilter extends GetView<OrderController> {
  const OrderCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(context, 'all', 'All'),
          ...controller.categories.map(
            (cat) => _buildCategoryChip(context, cat.name, cat.name.toUpperCase()),
          ),
        ],
      )),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String value, String label) {
    final isSelected = controller.selectedCategory.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTypography.chip.copyWith(
            color: isSelected ? AppColors.white : AppColors.brownDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => controller.setSelectedCategory(value),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.brownNormal,
        checkmarkColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.brownNormal : AppColors.greyLightActive,
          ),
        ),
      ),
    );
  }
}