import 'package:chiroku_cafe/feature/cashier/cashier_cart/models/cashier_cart_item_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final int? maxStock;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onQuantityChanged,
    this.maxStock,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _quantityController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity && !_isEditing) {
      _quantityController.text = widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _handleQuantitySubmit() {
    final newQuantity =
        int.tryParse(_quantityController.text) ?? widget.item.quantity;

    if (newQuantity <= 0) {
      _quantityController.text = '1';
      widget.onQuantityChanged(1);
    } else if (widget.maxStock != null && newQuantity > widget.maxStock!) {
      _quantityController.text = widget.maxStock.toString();
      widget.onQuantityChanged(widget.maxStock!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok maksimal: ${widget.maxStock}'),
          backgroundColor: AppColors.warningNormal,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      widget.onQuantityChanged(newQuantity);
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => widget.onRemove(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.alertNormal,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppColors.white, size: 28),
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
                  color: AppColors.greyLightActive,
                  borderRadius: BorderRadius.circular(8),
                  image:
                      widget.item.imageUrl != null &&
                          widget.item.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    widget.item.imageUrl == null ||
                        widget.item.imageUrl!.isEmpty
                    ? const Icon(
                        Icons.coffee,
                        size: 40,
                        color: AppColors.brownNormal,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.productName,
                      style: AppTypography.h6.copyWith(
                        color: AppColors.brownDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (widget.item.category != null)
                      Text(
                        widget.item.category!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.greyNormalHover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(widget.item.price),
                      style: AppTypography.priceSmall.copyWith(
                        color: AppColors.brownNormal,
                      ),
                    ),
                    if (widget.maxStock != null)
                      Text(
                        'Stock: ${widget.maxStock}',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.greyNormalHover,
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
                        onPressed: widget.onDecrease,
                        icon: const Icon(
                          Icons.remove_circle,
                          color: AppColors.brownNormal,
                        ),
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = true;
                          });
                          _quantityController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _quantityController.text.length,
                          );
                        },
                        child: Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? AppColors.brownLight
                                : AppColors.greyLightActive,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isEditing
                                  ? AppColors.brownNormal
                                  : AppColors.greyNormal,
                              width: _isEditing ? 2 : 1,
                            ),
                          ),
                          child: _isEditing
                              ? TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.h6.copyWith(
                                    color: AppColors.brownDark,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _handleQuantitySubmit(),
                                  onTapOutside: (_) => _handleQuantitySubmit(),
                                  autofocus: true,
                                )
                              : Text(
                                  '${widget.item.quantity}',
                                  style: AppTypography.h6.copyWith(
                                    color: AppColors.brownDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onIncrease,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.brownNormal,
                        ),
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(widget.item.total),
                    style: AppTypography.bodyMediumBold.copyWith(
                      color: AppColors.brownDark,
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

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
