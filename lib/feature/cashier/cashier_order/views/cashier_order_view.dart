
import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_app_bar_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_category_filter_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_floating_action_button_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_menu_grid_widget.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrderPage extends GetView<OrderController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const OrderAppBar(),
      body: const Column(
        children: [
          // Search Bar
          OrderSearchBar(),

          // Category Filter
          OrderCategoryFilter(),

          // Menu Grid
          OrderMenuGrid(),
        ],
      ),
      floatingActionButton: const OrderFloatingCartButton(),
    );
  }
}