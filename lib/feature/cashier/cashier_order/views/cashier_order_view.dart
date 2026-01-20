import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_category_filter_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_menu_grid_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      init: OrderController(),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.greyLight,
        appBar: AppBar(
          title: Text('Browse Menu', style: AppTypography.appBarTitle),
          backgroundColor: AppColors.brownNormal,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: const [
            OrderSearchBar(),
            OrderCategoryFilter(),
            Expanded(child: OrderMenuGrid()),
          ],
        ),
      ),
    );
  }
}