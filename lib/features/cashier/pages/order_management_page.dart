import 'package:chiroku_cafe/shared/models/order_models.dart';
import 'package:chiroku_cafe/shared/repositories/order/order_service.dart';
import 'package:chiroku_cafe/shared/widgets/cancel_order_dialog.dart';
import 'package:chiroku_cafe/configs/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final OrderService _orderService = OrderService();
  final supabase = Supabase.instance.client;

  List<OrderModel> activeOrders = [];
  bool isLoading = false;
  StreamSubscription? _ordersSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadActiveOrders();
    _setupRealtimeUpdates();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    // Realtime subscription untuk orders
    _ordersSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((data) {
          if (mounted) {
            _loadActiveOrders();
          }
        });

    // Periodic refresh setiap 15 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _loadActiveOrders();
      }
    });
  }

  Future<void> _loadActiveOrders() async {
    setState(() => isLoading = true);
    try {
      final orders = await _orderService.getOrders();
      setState(() {
        activeOrders = orders.where((order) {
          // Keep non-completed orders
          if (order.orderStatus != 'completed') return true;

          // If order is 'completed' (kitchen done), keep it active until the table becomes available
          final tableStatus = order.tableStatus ?? 'available';
          return tableStatus != 'available';
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load orders: $e',
          backgroundColor: AppColors.brownDarkActive,
          colorText: AppColors.white,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _markOrderDone(OrderModel order) async {
    try {
      String newStatus;
      String successMessage;

      // Flow status:
      // pending → preparing → ready → paid → completed
      switch (order.orderStatus.toLowerCase()) {
        case 'pending':
          newStatus = 'preparing';
          successMessage = 'Order #${order.id} is now being prepared';
          break;
        case 'preparing':
          newStatus = 'ready';
          successMessage = 'Order #${order.id} is ready for pickup/serving';
          break;
        case 'ready':
          newStatus = 'paid';
          successMessage = 'Order #${order.id} marked as paid';
          break;
        case 'paid':
          // Final step - mark as completed and free table
          final success = await _orderService.completeOrder(order.id);
          if (success) {
            Get.snackbar(
              'Completed',
              'Order #${order.id} completed successfully! Table is now available.',
              backgroundColor: AppColors.brownNormalActive,
              colorText: AppColors.white,
            );
            _loadActiveOrders();
          } else {
            throw Exception('Failed to complete order');
          }
          return;
        default:
          Get.snackbar(
            'Info',
            'Order #${order.id} is already completed',
            backgroundColor: AppColors.brownNormal,
            colorText: AppColors.white,
          );
          return;
      }

      // Update status for pending/preparing/ready stages
      await _orderService.updateOrderStatus(order.id, newStatus);

      Get.snackbar(
        'Success',
        successMessage,
        backgroundColor: AppColors.brownNormalActive,
        colorText: AppColors.white,
      );
      _loadActiveOrders();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order: $e',
        backgroundColor: AppColors.brownDarkActive,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> _handleCancelOrder(OrderModel order) async {
    final customerName = order.customerName ?? 'Walk-in Customer';

    final result = await showCancelOrderDialog(
      context: context,
      orderId: order.id,
      customerName: customerName,
      onCancelled: () {
        _loadActiveOrders(); // Refresh the list
      },
    );

    if (result == true) {
      // Order was cancelled, refresh the list
      _loadActiveOrders();
    }
  }

  // Helper methods for dynamic button text and styling
  String _getActionButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Mulai Persiapan';
      case 'preparing':
        return 'Tandai Siap';
      case 'ready':
        return 'Tandai Dibayar';
      case 'paid':
        return 'Selesaikan Pesanan';
      default:
        return 'Update Status';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done_all;
      case 'paid':
        return Icons.check_circle;
      default:
        return Icons.update;
    }
  }

  Color _getStatusButtonColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.brownNormal;
      case 'preparing':
        return AppColors.brownNormalHover;
      case 'ready':
        return AppColors.brownNormalActive;
      case 'paid':
        return AppColors.brownDark;
      default:
        return AppColors.brownNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      appBar: AppBar(
        title: Text(
          'Kelola Pesanan',
          style: TextStyle(
            fontStyle: GoogleFonts.montserrat().fontStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : activeOrders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadActiveOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(activeOrders[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: AppColors.brownLightActive,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.brownNormalHover,
              fontStyle: GoogleFonts.montserrat().fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'color': AppColors.brownNormal, 'text': 'On Process'};
      case 'preparing':
        return {'color': AppColors.brownNormalHover, 'text': 'On Process'};
      case 'ready':
        return {'color': AppColors.brownNormalActive, 'text': 'On Process'};
      case 'paid':
        return {'color': AppColors.brownNormal, 'text': 'Complete'};
      case 'completed':
        return {'color': AppColors.brownNormal, 'text': 'Complete'};
      case 'cancelled':
        return {'color': AppColors.brownDark, 'text': 'Cancel'};
      case 'void':
        return {'color': AppColors.brownDarkHover, 'text': 'Cancel'};
      default:
        return {'color': AppColors.brownDarkHover, 'text': status};
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusInfo = _getStatusInfo(order.orderStatus);
    final statusColor = statusInfo['color'];
    final statusText = statusInfo['text'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.tableId != null)
              Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 16,
                    color: AppColors.brownNormalHover,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Meja: ${order.tableId}',
                    style: TextStyle(
                      color: AppColors.brownNormalHover,
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.brownNormalHover,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy - HH:mm').format(order.createdAt),
                  style: TextStyle(
                    color: AppColors.brownNormalHover,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Items:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontStyle: GoogleFonts.montserrat().fontStyle,
              ),
            ),
            const SizedBox(height: 4),
            ...(order.items
                    ?.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.qty}x ${item.menuName ?? 'Unknown Item'}',
                                style: TextStyle(
                                  fontStyle: GoogleFonts.montserrat().fontStyle,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(item.subtotal),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: GoogleFonts.montserrat().fontStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList() ??
                []),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
                Text(
                  _formatCurrency(order.total),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button - text changes based on status
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markOrderDone(order),
                icon: Icon(
                  _getStatusIcon(order.orderStatus),
                  color: Colors.white,
                ),
                label: Text(
                  _getActionButtonText(order.orderStatus),
                  style: TextStyle(
                    fontStyle: GoogleFonts.montserrat().fontStyle,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusButtonColor(order.orderStatus),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Cancel Order Button (only for pending and preparing orders)
            if (order.orderStatus == 'pending' ||
                order.orderStatus == 'preparing')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleCancelOrder(order),
                  icon: Icon(Icons.cancel_outlined, color: AppColors.brownDark),
                  label: Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      fontStyle: GoogleFonts.montserrat().fontStyle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.brownDark),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
