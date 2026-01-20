import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import '../models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:intl/intl.dart';

class OrderMenuGrid extends GetView<OrderController> {
  const OrderMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredMenus.isEmpty) {
        return Center(
          child: Text(
            'No menu found',
            style: AppTypography.bodyMedium,
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.filteredMenus.length,
          itemBuilder: (context, index) {
            final menu = controller.filteredMenus[index];
            return _buildMenuCard(context, menu);
          },
        ),
      );
    });
  }

  Widget _buildMenuCard(BuildContext context, MenuModel menu) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 100,
              width: double.infinity,
              color: AppColors.greyLightActive,
              child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                  ? Image.network(menu.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.fastfood, size: 40, color: AppColors.greyNormal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: AppTypography.bodyMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (menu.description != null && menu.description!.isNotEmpty)
                  Text(
                    menu.description!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(menu.price),
                  style: AppTypography.priceSmall.copyWith(color: AppColors.brownNormal),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: menu.isAvailable
                            ? AppColors.successLight
                            : AppColors.alertLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menu.isAvailable ? 'Available' : 'Not Available',
                        style: AppTypography.label.copyWith(
                          color: menu.isAvailable
                              ? AppColors.successNormal
                              : AppColors.alertNormal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stock: ${menu.stock}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.brownNormal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}