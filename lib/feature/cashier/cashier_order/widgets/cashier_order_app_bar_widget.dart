import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderAppBar extends GetView<OrderController> implements PreferredSizeWidget {
  const OrderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
            controller.selectedTable.value != null
                ? 'Order - ${controller.selectedTable.value?.tableName ?? "Table"}'
                : 'Browse Menu',
            style: TextStyle(
              fontStyle: GoogleFonts.montserrat().fontStyle,
              fontWeight: FontWeight.bold,
            ),
          )),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        _buildCartButton(),
      ],
    );
  }

  Widget _buildCartButton() {
    return Obx(() => Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () async {
                controller.navigateToCart();
                controller.updateCartCount();
              },
              tooltip: 'Shopping Cart',
            ),
            if (controller.cartCount.value > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    controller.cartCount.value > 99
                        ? '99+'
                        : controller.cartCount.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



