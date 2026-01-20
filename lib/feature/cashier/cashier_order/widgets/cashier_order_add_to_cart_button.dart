import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddToCartButton extends StatelessWidget {
  final MenuModel menu;

  const AddToCartButton({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return IconButton(
      onPressed: menu.isAvailable && menu.stock > 0
          ? () => cartController.addToCart(menu)
          : null,
      icon: Icon(
        Icons.add_circle,
        color: menu.isAvailable && menu.stock > 0
            ? AppColors.brownNormal
            : AppColors.greyNormal,
        size: 32,
      ),
      tooltip: 'Add to cart',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
