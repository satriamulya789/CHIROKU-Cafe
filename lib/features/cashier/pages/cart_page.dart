import 'package:chiroku_cafe/shared/repositories/cart/cart_controller.dart';
import 'package:chiroku_cafe/shared/models/table_models.dart';
import 'package:chiroku_cafe/shared/repositories/table/table_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartController cartController;
  // If navigated here from OrderPage with a selected table, keep it so we
  // can forward it to Checkout and preserve context.
  TableModel? selectedTable;
  final TableService _tableService = TableService();

  @override
  void initState() {
    super.initState();
    cartController = Get.put(CartController());
    // Refresh cart data when page is opened
    _refreshCart();
  }

  // Refresh cart every time page becomes visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshCart();
    // Read table argument if provided and keep it
    final args = Get.arguments as Map<String, dynamic>?;
    selectedTable = args?['table'] as TableModel?;

    // If a table was passed, verify its current status from the server.
    if (selectedTable != null) {
      final tableId = selectedTable?.id;
      if (tableId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final fresh = await _tableService.getTableById(tableId);
            if (fresh == null) return;
            if (fresh.status.toLowerCase() == 'reserved') {
              // Table is reserved now; inform user and clear selection
              selectedTable = null;
              if (mounted) {
                Get.snackbar(
                  'Meja Reserved',
                  'Meja ${fresh.tableName} sedang direservasi dan tidak bisa digunakan. Silakan pilih meja lain atau lanjut tanpa meja.',
                  backgroundColor: Colors.orange[700],
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
                setState(() {});
              }
            } else {
              // update local selectedTable with fresh data
              selectedTable = fresh;
              if (mounted) setState(() {});
            }
          } catch (e) {
            // Ignore fetch errors; keep passed table as-is
          }
        });
      }
    }
  }

  void _refreshCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            if (cartController.cartItems.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () => _showClearCartDialog(context, cartController),
            );
          }),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (cartController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty cart state
        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCart(context);
        }

        // Cart with items
        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await cartController.fetchCartItems();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return _buildCartItem(context, item, cartController);
                  },
                ),
              ),
            ),

            // Order Summary
            _buildOrderSummary(context, cartController),
          ],
        );
      }),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (selectedTable != null) {
                Get.toNamed(
                  '/cashier/order',
                  arguments: {'table': selectedTable},
                );
              } else {
                Get.toNamed('/cashier/order');
              }
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(
              'Browse Menu',
              style: TextStyle(
                fontStyle: GoogleFonts.montserrat().fontStyle,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    dynamic item,
    CartController controller,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => controller.removeItem(item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl == null || item.imageUrl!.isEmpty
                    ? Icon(Icons.coffee, size: 40, color: Colors.brown[300])
                    : null,
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.category != null)
                      Text(
                        item.category ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(item.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.decreaseQuantity(item),
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        iconSize: 24,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: GoogleFonts.montserrat().fontStyle,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.increaseQuantity(item),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        iconSize: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(item.price * item.quantity),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Note Field
          TextField(
            onChanged: (value) => controller.setOrderNote(value),
            decoration: InputDecoration(
              labelText: 'Order Note (Optional)',
              hintText: 'Add special instructions...',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          const Divider(height: 24),

          // Price Breakdown
          Obx(
            () => Column(
              children: [
                _buildPriceRow('Subtotal', controller.subtotal),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showDiscountDialog(context, controller),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Discount',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontStyle: GoogleFonts.montserrat().fontStyle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Text(
                              '${controller.discountPercentage.value.toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                        ],
                      ),
                      Text(
                        '- ${_formatCurrency(controller.discountAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600,
                          fontStyle: GoogleFonts.montserrat().fontStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriceRow('Tax (10%)', controller.taxAmount),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                    Text(
                      _formatCurrency(controller.total),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontStyle: GoogleFonts.montserrat().fontStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkout Button
          ElevatedButton(
            onPressed: () => _processCheckout(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Process Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontStyle: GoogleFonts.montserrat().fontStyle,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontStyle: GoogleFonts.montserrat().fontStyle,
          ),
        ),
      ],
    );
  }

  // ==================== DIALOGS ====================

  void _showDiscountDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Apply Discount',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiscountOption(controller, 0, 'No Discount'),
              _buildDiscountOption(controller, 10, '10% Off'),
              _buildDiscountOption(controller, 20, '20% Off'),
              _buildDiscountOption(controller, 50, '50% Off'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountOption(
    CartController controller,
    double percentage,
    String label,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      leading: Radio<double>(
        value: percentage,
        groupValue: controller.discountPercentage.value,
        onChanged: (value) {
          if (value != null) {
            controller.setDiscount(value);
          }
          Get.back();
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Cart?',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items?',
          style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(fontStyle: GoogleFonts.montserrat().fontStyle),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear',
              style: TextStyle(
                fontStyle: GoogleFonts.montserrat().fontStyle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, CartController controller) {
    // Navigate to checkout page
    if (selectedTable != null) {
      // Verify table status before forwarding
      final tableId = selectedTable?.id;
      if (tableId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final fresh = await _tableService.getTableById(tableId);
            if (fresh != null && fresh.status.toLowerCase() == 'reserved') {
              // Do not forward reserved table to checkout
              Get.snackbar(
                'Meja Reserved',
                'Meja ${fresh.tableName} sedang direservasi dan tidak dapat digunakan. Anda dapat memilih meja lain di halaman Checkout.',
                backgroundColor: Colors.orange[700],
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
              Get.toNamed('/cashier/checkout');
            } else {
              Get.toNamed(
                '/cashier/checkout',
                arguments: {'table': selectedTable},
              );
            }
          } catch (e) {
            // On error, just continue without passing table
            Get.toNamed('/cashier/checkout');
          }
        });
      }
    } else {
      Get.toNamed('/cashier/checkout');
    }
  }

  // ==================== HELPERS ====================

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
