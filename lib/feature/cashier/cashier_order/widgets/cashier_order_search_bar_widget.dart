import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OrderSearchBar extends GetView<OrderController> {
  const OrderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                  ),
                  onPressed: controller.clearSearch,
                  tooltip: 'Clear search',
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}