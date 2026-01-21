import 'package:chiroku_cafe/shared/services/menu_stock_service.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';

class StockMonitorWidget extends StatefulWidget {
  const StockMonitorWidget({super.key});

  @override
  State<StockMonitorWidget> createState() => _StockMonitorWidgetState();
}

class _StockMonitorWidgetState extends State<StockMonitorWidget> {
  final MenuStockService _stockService = MenuStockService();
  List<Map<String, dynamic>> lowStockItems = [];
  List<Map<String, dynamic>> outOfStockItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    setState(() => isLoading = true);

    try {
      final lowStock = await _stockService.getLowStockMenus();
      final outOfStock = await _stockService.getOutOfStockMenus();

      setState(() {
        lowStockItems = lowStock;
        outOfStockItems = outOfStock;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brownDark),
      );
    }

    final totalIssues = lowStockItems.length + outOfStockItems.length;

    if (totalIssues == 0) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stok Aman', style: AppTypography.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Semua menu memiliki stok yang cukup',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.greyNormal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brownLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.brownDark,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Peringatan Stok', style: AppTypography.h3),
                      const SizedBox(height: 4),
                      Text(
                        '$totalIssues menu memerlukan perhatian',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.greyNormal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStockData,
                  color: AppColors.brownDark,
                ),
              ],
            ),
          ),

          // Out of Stock Items
          if (outOfStockItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'HABIS',
                      style: AppTypography.caption.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${outOfStockItems.length} menu',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.greyNormal,
                    ),
                  ),
                ],
              ),
            ),
            ...outOfStockItems.map(
              (item) => _buildStockItem(item, isOutOfStock: true),
            ),
          ],

          // Low Stock Items
          if (lowStockItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'STOK RENDAH',
                      style: AppTypography.caption.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lowStockItems.length} menu',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.greyNormal,
                    ),
                  ),
                ],
              ),
            ),
            ...lowStockItems
                .where((item) => (item['stock'] as int) > 0)
                .map((item) => _buildStockItem(item)),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStockItem(
    Map<String, dynamic> item, {
    bool isOutOfStock = false,
  }) {
    final stock = item['stock'] as int;
    final name = item['name'] as String;
    final isAvailable = item['is_available'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOutOfStock ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOutOfStock ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOutOfStock ? Icons.cancel : Icons.warning,
            color: isOutOfStock ? Colors.red.shade700 : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Stok: $stock',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.greyNormal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Tidak Tersedia',
                          style: AppTypography.caption.copyWith(
                            color: Colors.red.shade700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.greyNormal),
        ],
      ),
    );
  }
}
