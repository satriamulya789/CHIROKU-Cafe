import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/widgets/cashier_cart_cart_item_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/widgets/cashier_cart_cart_summary_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/widgets/cashier_cart_empty_cart_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: AppTypography.appBarTitle.copyWith(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.brownNormal,
        foregroundColor: AppColors.white,
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () => _showClearCartDialog(context, controller),
            );
          }),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.brownNormal,
            ),
          );
        }

        // Empty cart state
        if (controller.cartItems.isEmpty) {
          return const EmptyCartWidget();
        }

        // Cart with items
        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchCartItems();
                },
                color: AppColors.brownNormal,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return CartItemWidget(
                      item: item,
                      onIncrease: () => controller.increaseQuantity(item),
                      onDecrease: () => controller.decreaseQuantity(item),
                      onRemove: () => controller.removeItem(item.id),
                    );
                  },
                ),
              ),
            ),

            // Order Summary
            CartSummaryWidget(controller: controller),
          ],
        );
      }),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear Cart?',
          style: AppTypography.h5.copyWith(
            color: AppColors.brownDark,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.greyNormalHover,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(
                color: AppColors.greyNormalHover,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertNormal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear',
              style: AppTypography.button.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}