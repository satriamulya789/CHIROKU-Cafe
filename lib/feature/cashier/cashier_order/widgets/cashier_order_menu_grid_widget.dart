import 'package:chiroku_cafe/feature/cashier/cashier_order/controllers/cashier_order_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/widgets/cashier_order_menu_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderMenuGrid extends GetView<OrderController> {
  const OrderMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        // Loading State
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Empty State
        if (controller.filteredMenus.isEmpty) {
          return _buildEmptyState();
        }

        // Menu Grid
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: Theme.of(context).primaryColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: controller.filteredMenus.length,
            itemBuilder: (context, index) {
              return OrderMenuCard(
                menu: controller.filteredMenus[index],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No menu found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          const SizedBox(height: 24),
          if (controller.searchQuery.value.isNotEmpty ||
              controller.selectedCategory.value != 'all')
            ElevatedButton.icon(
              onPressed: () {
                controller.clearSearch();
                controller.setSelectedCategory('all');
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Clear Filters',
                style: TextStyle(
                  fontStyle: GoogleFonts.montserrat().fontStyle,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}