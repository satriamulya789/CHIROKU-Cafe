import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderFloatingCartButton extends GetView<OrderController> {
  const OrderFloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.cartCount.value > 0
        ? FloatingActionButton.extended(
            onPressed: controller.navigateToCart,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4,
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            label: Text(
              'View Cart (${controller.cartCount.value})',
              style: TextStyle(
                fontStyle: GoogleFonts.montserrat().fontStyle,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        : const SizedBox.shrink());
  }
}