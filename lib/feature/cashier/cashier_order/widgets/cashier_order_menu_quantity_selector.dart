import 'package:chiroku_cafe/feature/cashier/cashier_cart/controllers/cashier_cart_controller.dart';
import 'package:chiroku_cafe/feature/cashier/cashier_order/models/cashier_order_menu_model.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MenuQuantitySelector extends StatefulWidget {
  final MenuModel menu;

  const MenuQuantitySelector({super.key, required this.menu});

  @override
  State<MenuQuantitySelector> createState() => _MenuQuantitySelectorState();
}

class _MenuQuantitySelectorState extends State<MenuQuantitySelector> {
  final CartController _cartController = Get.find<CartController>();
  late TextEditingController _quantityController;
  int _quantity = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _syncWithCart();
  }

  void _syncWithCart() {
    final existingItem = _cartController.cartItems.firstWhereOrNull(
      (item) => item.menuId == widget.menu.id,
    );

    _quantity = existingItem?.quantity ?? 0;
    if (!_isEditing) {
      _quantityController.text = _quantity.toString();
    }
  }

  void _updateQuantityFromCart() {
    _syncWithCart();
    setState(() {});
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _handleIncrease() {
    if (_quantity >= widget.menu.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum stock: ${widget.menu.stock}'),
          backgroundColor: AppColors.warningNormal,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_quantity == 0) {
      // Add new item
      _cartController.addToCart(widget.menu, quantity: 1);
    } else {
      // Increase existing item
      final existingItem = _cartController.cartItems.firstWhereOrNull(
        (item) => item.menuId == widget.menu.id,
      );
      if (existingItem != null) {
        _cartController.increaseQuantity(
          existingItem,
          maxStock: widget.menu.stock,
        );
      }
    }

    // Update UI after a short delay to get updated cart
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _updateQuantityFromCart();
    });
  }

  void _handleDecrease() {
    if (_quantity <= 0) return;

    final existingItem = _cartController.cartItems.firstWhereOrNull(
      (item) => item.menuId == widget.menu.id,
    );

    if (existingItem != null) {
      _cartController.decreaseQuantity(existingItem);
    }

    // Update UI after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _updateQuantityFromCart();
    });
  }

  void _handleQuantitySubmit() {
    final newQuantity = int.tryParse(_quantityController.text) ?? _quantity;

    if (newQuantity <= 0) {
      // Remove from cart
      final existingItem = _cartController.cartItems.firstWhereOrNull(
        (item) => item.menuId == widget.menu.id,
      );
      if (existingItem != null) {
        _cartController.removeItem(existingItem.id);
      }
      setState(() {
        _quantity = 0;
        _quantityController.text = '0';
        _isEditing = false;
      });
    } else if (newQuantity > widget.menu.stock) {
      // Limit to stock
      _quantityController.text = widget.menu.stock.toString();
      _handleSetQuantity(widget.menu.stock);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum stock: ${widget.menu.stock}'),
          backgroundColor: AppColors.warningNormal,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _handleSetQuantity(newQuantity);
    }

    setState(() {
      _isEditing = false;
    });
  }

  void _handleSetQuantity(int newQuantity) {
    final existingItem = _cartController.cartItems.firstWhereOrNull(
      (item) => item.menuId == widget.menu.id,
    );

    if (existingItem != null) {
      // Update existing
      _cartController.updateQuantity(
        existingItem.id,
        newQuantity,
        maxStock: widget.menu.stock,
      );
    } else if (newQuantity > 0) {
      // Add new
      _cartController.addToCart(widget.menu, quantity: newQuantity);
    }

    // Update UI
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _updateQuantityFromCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to cart changes
    return Obx(() {
      // Trigger rebuild when cart changes
      _cartController.cartItems.length;
      _syncWithCart();

      if (_quantity == 0) {
        // Show only + button
        return IconButton(
          onPressed: widget.menu.isAvailable && widget.menu.stock > 0
              ? _handleIncrease
              : null,
          icon: Icon(
            Icons.add_circle,
            color: widget.menu.isAvailable && widget.menu.stock > 0
                ? AppColors.brownNormal
                : AppColors.greyNormal,
            size: 32,
          ),
          tooltip: 'Add to cart',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }

      // Show quantity controls
      return Container(
        decoration: BoxDecoration(
          color: AppColors.brownLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.brownNormal, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrease button
            InkWell(
              onTap: _handleDecrease,
              child: const Icon(
                Icons.remove_circle,
                color: AppColors.brownNormal,
                size: 24,
              ),
            ),
            const SizedBox(width: 4),

            // Quantity display/input
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
                width: 35,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _isEditing ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brownDark,
                          fontWeight: FontWeight.bold,
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
                        '$_quantity',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brownDark,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            const SizedBox(width: 4),

            // Increase button
            InkWell(
              onTap: _handleIncrease,
              child: const Icon(
                Icons.add_circle,
                color: AppColors.brownNormal,
                size: 24,
              ),
            ),
          ],
        ),
      );
    });
  }
}
