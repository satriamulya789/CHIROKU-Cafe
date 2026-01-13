import 'package:chiroku_cafe/feature/admin/admin_manage_control/admin_manage_controll_edit/admin_edit_menu/models/admin_edit_menu_model.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';

class OrderMenuCard extends GetView<OrderController> {
  final MenuModel menu;

  const OrderMenuCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(context, constraints),

              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      Text(
                        menu.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (menu.description != null &&
                          menu.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          menu.description!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),

                      // Price
                      Text(
                        currencyFormat.format(menu.price),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Quantity Controls & Add Button
                      _buildQuantityControls(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, BoxConstraints constraints) {
    return Stack(
      children: [
        // Main Image
        Container(
          height: constraints.maxHeight * 0.5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            image: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(menu.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: menu.imageUrl == null || menu.imageUrl!.isEmpty
              ? Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                )
              : null,
        ),

        // Category Badge
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              menu.category!.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
          ),
        ),

        // Out of Stock Badge
        if (menu.stock <= 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Out of Stock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Obx(() {
      final quantity = controller.getQuantity(menu.id.toString());

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Quantity controls
          Flexible(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => controller.decreaseQuantity(menu.id.toString()),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.remove,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => controller.increaseQuantity(menu.id.toString()),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Add to cart button
          InkWell(
            onTap: menu.stock > 0 ? () => controller.addToCart(menu) : null,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: menu.stock > 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add_shopping_cart,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }
}
