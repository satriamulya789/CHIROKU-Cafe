import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_category_filter_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_menu_grid_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_search_bar_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text('Browse Menu', style: AppTypography.appBarTitle),
        backgroundColor: AppColors.brownNormal,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Cart Icon with Badge
          Obx(() {
            final itemCount = cartController.itemCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Get.toNamed(AppRoutes.cashierCart);
                  },
                  tooltip: 'View Cart',
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.alertNormal,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        itemCount > 9 ? '9+' : '$itemCount',
                        style: AppTypography.badge.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const OrderSearchBar(),
          const OrderCategoryFilter(),
          Expanded(child: const OrderMenuGrid()),
        ],
      ),
    );
  }
}
