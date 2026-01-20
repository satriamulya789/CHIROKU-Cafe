import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddToCartButton extends StatelessWidget {
  final MenuModel menu;

  const AddToCartButton({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return ElevatedButton.icon(
      onPressed: menu.isAvailable && menu.stock > 0
          ? () => cartController.addToCart(menu)
          : null,
      icon: const Icon(Icons.add_shopping_cart, size: 18),
      label: Text(
        'Add to Cart',
        style: AppTypography.buttonSmall.copyWith(color: AppColors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownNormal,
        disabledBackgroundColor: AppColors.greyNormal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}
