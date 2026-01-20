import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import '../models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:intl/intl.dart';
import 'cashier_order_menu_quantity_selector.dart';

class OrderMenuGrid extends GetView<OrderController> {
  const OrderMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.brownNormal),
        );
      }
      if (controller.filteredMenus.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.greyNormal),
              const SizedBox(height: 16),
              Text(
                'No menu found',
                style: AppTypography.h6.copyWith(color: AppColors.greyNormal),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.brownNormal,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.62, // Adjusted for cleaner layout
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: AppColors.greyLight,
                  child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                      ? Image.network(
                          menu.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: AppColors.greyNormal,
                          ),
                        )
                      : Icon(
                          Icons.fastfood_outlined,
                          size: 40,
                          color: AppColors.greyNormal,
                        ),
                ),
                // Availability Badge overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: menu.isAvailable
                          ? AppColors.successNormal.withOpacity(0.9)
                          : AppColors.alertNormal.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      menu.isAvailable ? 'Available' : 'Sold Out',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: AppTypography.bodyLargeBold.copyWith(
                        color: AppColors.brownDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(menu.price),
                      style: AppTypography.priceMedium.copyWith(
                        color: AppColors.brownNormal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (menu.description != null &&
                        menu.description!.isNotEmpty)
                      Expanded(
                        child: Text(
                          menu.description!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.greyNormalHover,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(height: 8),

                    // Stock and Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock',
                              style: AppTypography.label.copyWith(
                                color: AppColors.greyNormal,
                              ),
                            ),
                            Text(
                              '${menu.stock}',
                              style: AppTypography.bodySmallBold.copyWith(
                                color: menu.stock > 10
                                    ? AppColors.brownNormal
                                    : AppColors.alertNormal,
                              ),
                            ),
                          ],
                        ),
                        MenuQuantitySelector(menu: menu),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
