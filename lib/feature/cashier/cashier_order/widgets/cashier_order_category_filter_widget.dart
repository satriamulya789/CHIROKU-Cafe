import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';

class OrderCategoryFilter extends GetView<OrderController> {
  const OrderCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(context, 'all', 'All'),
              ...controller.categories.map(
                (cat) => _buildCategoryChip(
                  context,
                  cat.name,
                  cat.name.toUpperCase(),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String value, String label) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == value;

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) => controller.setSelectedCategory(value),
          backgroundColor: Colors.white,
          selectedColor: Theme.of(context).primaryColor,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300] ?? Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          pressElevation: 4,
        ),
      );
    });
  }
}

