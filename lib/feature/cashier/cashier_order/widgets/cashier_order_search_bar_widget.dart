import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OrderSearchBar extends GetView<OrderController> {
  const OrderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brownNormal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.greyNormal),
          prefixIcon: Icon(Icons.search, color: AppColors.brownNormal),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}