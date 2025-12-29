import 'package:chiroku_cafe/features/cashier/pages/receipt_page.dart';
import 'package:chiroku_cafe/shared/models/cart_models.dart';
import 'package:chiroku_cafe/shared/repositories/cart/cart_service.dart';
import 'package:chiroku_cafe/shared/repositories/order/order_service.dart';
import 'package:chiroku_cafe/shared/repositories/table/table_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final TableService _tableService = TableService();

  List<CartItemModel> cartItems = [];
  int? selectedTableId;
  String selectedPaymentMethod = 'cash';
  String customerName = '';
  double serviceFee = 0;
  double taxRate = 0.10; // 10%
  double discount = 0;
  bool isProcessing = false;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();

  double cashAmount = 0;
  double changeAmount = 0;
  bool isCashValid = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();

    // If navigated here from a table tap, Get.arguments may contain the table
    // object. Preselect the table in the checkout form so cashier doesn't need
    // to pick it again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args is Map && args['table'] != null) {
        try {
          final table = args['table'];
          final tableId = table.id is int
              ? table.id as int
              : int.tryParse(table.id.toString());
          if (tableId != null) {
            // Verify current status from server to avoid preselecting reserved tables
            _tableService
                .getTableById(tableId)
                .then((fresh) {
                  if (fresh == null) return;
                  if (fresh.status.toLowerCase() == 'reserved') {
                    Get.snackbar(
                      'Meja Reserved',
                      'Meja ${fresh.tableName} sedang direservasi dan tidak bisa dipilih otomatis. Silakan pilih meja lain atau lanjut tanpa meja.',
                      backgroundColor: Colors.orange[700],
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  } else {
                    setState(() {
                      selectedTableId = tableId;
                    });
                  }
                })
                .catchError((_) {
                  // If fetching fails, fall back to using passed value
                  setState(() {
                    selectedTableId = tableId;
                  });
                });
          }
        } catch (e) {
          // ignore malformed argument
        }
      }
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItems() async {
    final items = await _cartService.getCartItems();
    setState(() {
      cartItems = items;
      // Service fee 5% dari subtotal
      serviceFee = subtotal * 0.05;
    });
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get tax {
    return subtotal * taxRate;
  }

  double get total {
    return subtotal + serviceFee + tax - discount;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _showCheckoutConfirmation() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Keranjang kosong',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 22),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Konfirmasi Pembayaran',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationRow(
                'Total Pembayaran',
                _formatCurrency(total),
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              _buildConfirmationRow(
                'Metode Pembayaran',
                _getPaymentMethodLabel(selectedPaymentMethod),
              ),
              if (customerName.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildConfirmationRow('Nama Pelanggan', customerName),
              ],
              if (selectedTableId != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Meja akan direservasi setelah pembayaran.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Lanjutkan pembayaran?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Lanjut Payment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _processCheckout();
    }
  }

  Future<void> _processCheckout() async {
    setState(() => isProcessing = true);

    try {
      // Get customer name from controller
      final finalCustomerName = _customerNameController.text.trim();

      // 1. Create order
      final order = await _orderService.createOrder(
        cartItems: cartItems,
        tableId: selectedTableId,
        customerName: finalCustomerName.isNotEmpty ? finalCustomerName : null,
        serviceFee: serviceFee,
        tax: tax,
        discount: discount,
      );

      // 2. Process payment and update order status to 'paid'
      await _orderService.createPayment(
        orderId: order.id,
        paymentMethod: selectedPaymentMethod,
        amount: total,
      );

      // 3. Update order status to 'paid'
      await _orderService.updateOrderStatus(order.id, 'paid');

      // 4. Update table status to 'reserved' after payment (if table selected)
      if (selectedTableId != null) {
        try {
          await _tableService.updateTableStatus(selectedTableId!, 'reserved');
        } catch (e) {
          // Don't crash the checkout flow if table update fails. Inform cashier.
          if (mounted) {
            Get.snackbar(
              'Gagal Reservasi Meja',
              'Terjadi kesalahan saat mereservasi meja: ${e.toString()}',
              backgroundColor: Colors.orange[800],
              colorText: Colors.white,
            );
          }
        }
      }

      // 5. Clear cart
      await _cartService.clearCart();

      // 6. Get complete order data for receipt
      final orderData = await _orderService.getOrderDetailsWithItems(order.id);

      setState(() => isProcessing = false);

      // Show success and navigate to receipt
      if (mounted && orderData != null) {
        Get.snackbar(
          'Success',
          'Pembayaran berhasil! Meja ${selectedTableId != null ? "direservasi" : ""}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to receipt page and remove all previous routes
        Get.off(() => ReceiptPage(orderData: orderData));
      }
    } catch (e) {
      setState(() => isProcessing = false);

      if (mounted) {
        // Provide more specific error messages
        String errorMessage = 'Gagal memproses transaksi';
        if (e.toString().contains('customer_name')) {
          errorMessage =
              'Gagal menyimpan nama customer, tetapi pesanan tetap diproses';
        } else if (e.toString().contains('connection')) {
          errorMessage = 'Masalah koneksi database. Coba lagi.';
        } else {
          errorMessage =
              'Gagal memproses transaksi: ${e.toString().split('\n').first}';
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  void _calculateChange() {
    setState(() {
      cashAmount = double.tryParse(_cashController.text) ?? 0;
      changeAmount = cashAmount - total;
      isCashValid = cashAmount >= total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang kosong',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildSection(
                    'Ringkasan Pesanan',
                    Icons.receipt_long,
                    Column(
                      children: cartItems
                          .map((item) => _buildOrderItem(item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Table Selection
                  _buildSection(
                    'Pilih Meja (Opsional)',
                    Icons.table_restaurant,
                    FutureBuilder(
                      future: _tableService.getAvailableTables(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final tables = snapshot.data!;
                        return DropdownButtonFormField<int>(
                          value: selectedTableId,
                          decoration: InputDecoration(
                            hintText: 'Pilih meja...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tanpa meja'),
                            ),
                            ...tables.map((table) {
                              return DropdownMenuItem(
                                value: table.id,
                                child: Text(
                                  '${table.tableName} (Kapasitas: ${table.capacity})',
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) async {
                            // Reserve table when selected
                            if (value != null && value != selectedTableId) {
                              try {
                                final success = await _orderService
                                    .reserveTable(value);
                                if (success) {
                                  setState(() => selectedTableId = value);
                                  Get.snackbar(
                                    'Table Reserved',
                                    'Table has been reserved for this order',
                                    backgroundColor: Colors.blue[600],
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                } else {
                                  Get.snackbar(
                                    'Table Unavailable',
                                    'This table is currently occupied or reserved',
                                    backgroundColor: Colors.orange[600],
                                    colorText: Colors.white,
                                  );
                                }
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to reserve table: $e',
                                  backgroundColor: Colors.red[600],
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              setState(() => selectedTableId = value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Name
                  _buildSection(
                    'Nama Pelanggan (Opsional)',
                    Icons.person,
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama pelanggan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      onChanged: (value) {
                        setState(() => customerName = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  _buildSection(
                    'Metode Pembayaran',
                    Icons.payment,
                    Column(
                      children: [
                        _buildPaymentOption(
                          value: 'cash',
                          title: 'Tunai',
                          subtitle: 'Pembayaran dengan uang tunai',
                          icon: Icons.money,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          value: 'debit',
                          title: 'Kartu Debit',
                          subtitle: 'Pembayaran dengan kartu debit',
                          icon: Icons.credit_card,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          value: 'qris',
                          title: 'QRIS',
                          subtitle: 'Scan QR code untuk pembayaran',
                          icon: Icons.qr_code_scanner,
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          value: 'ewallet',
                          title: 'E-Wallet',
                          subtitle: 'GoPay, OVO, Dana, ShopeePay',
                          icon: Icons.account_balance_wallet,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Breakdown
                  _buildSection(
                    'Rincian Harga',
                    Icons.calculate,
                    Column(
                      children: [
                        _buildPriceRow('Subtotal', subtotal),
                        _buildPriceRow('Biaya Layanan (5%)', serviceFee),
                        _buildPriceRow('Pajak (10%)', tax),
                        if (discount > 0)
                          _buildPriceRow('Diskon', -discount, isDiscount: true),
                        const Divider(thickness: 2),
                        _buildPriceRow('Total', total, isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cash Payment Section
                  if (selectedPaymentMethod == 'cash') ...[
                    _buildSection(
                      'Pembayaran Tunai',
                      Icons.money,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Masukkan Uang Tunai',
                              border: OutlineInputBorder(),
                              errorText: isCashValid ? null : 'Uang tunai tidak mencukupi',
                            ),
                            onChanged: (_) => _calculateChange(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            changeAmount >= 0
                                ? 'Kembalian: ${_formatCurrency(changeAmount)}'
                                : 'Kurang: ${_formatCurrency(changeAmount.abs())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: changeAmount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _showCheckoutConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'Checkout - ${_formatCurrency(total)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
          if (item.imageUrl != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Text(
                  '${item.quantity} x ${_formatCurrency(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(item.totalPrice),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? Theme.of(context).primaryColor
                  : Colors.black,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(
    String label,
    String value, {
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: fontWeight ?? FontWeight.w600,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'debit':
        return 'Kartu Debit';
      case 'credit':
        return 'Kartu Kredit';
      default:
        return 'Tidak Diketahui';
    }
  }
}
