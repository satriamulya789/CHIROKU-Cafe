class CashierErrorModel {
  final String message;
  final String code;
  final int? statusCode;

  CashierErrorModel({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  // ==================== Validation Errors ====================

  /// Error when customer name is empty
  factory CashierErrorModel.customerNameEmpty() {
    return CashierErrorModel(
      message: 'Customer name must not be empty',
      code: 'customer_name_empty',
      statusCode: 400,
    );
  }

  /// Error when table number is empty
  factory CashierErrorModel.tableNumberEmpty() {
    return CashierErrorModel(
      message: 'Table number must not be empty',
      code: 'table_number_empty',
      statusCode: 400,
    );
  }

  /// Error when quantity is invalid
  factory CashierErrorModel.invalidQuantity() {
    return CashierErrorModel(
      message: 'Quantity must be greater than 0',
      code: 'invalid_quantity',
      statusCode: 400,
    );
  }

  /// Error when payment amount is invalid
  factory CashierErrorModel.invalidPaymentAmount() {
    return CashierErrorModel(
      message: 'Payment amount must be greater than or equal to total',
      code: 'invalid_payment_amount',
      statusCode: 400,
    );
  }

  /// Error when date range is invalid
  factory CashierErrorModel.invalidDateRange() {
    return CashierErrorModel(
      message: 'Invalid date range. End date must be after start date',
      code: 'invalid_date_range',
      statusCode: 400,
    );
  }

  // ==================== Cart Errors ====================

  /// Error when cart is empty
  factory CashierErrorModel.cartEmpty() {
    return CashierErrorModel(
      message: 'Cart is empty. Please add items to proceed.',
      code: 'cart_empty',
      statusCode: 400,
    );
  }

  /// Error when item not found in cart
  factory CashierErrorModel.itemNotFoundInCart() {
    return CashierErrorModel(
      message: 'Item not found in cart',
      code: 'item_not_found_in_cart',
      statusCode: 404,
    );
  }

  /// Error when failed to add item to cart
  factory CashierErrorModel.addToCartFailed() {
    return CashierErrorModel(
      message: 'Failed to add item to cart. Please try again.',
      code: 'add_to_cart_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update cart item
  factory CashierErrorModel.updateCartItemFailed() {
    return CashierErrorModel(
      message: 'Failed to update cart item. Please try again.',
      code: 'update_cart_item_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to remove item from cart
  factory CashierErrorModel.removeFromCartFailed() {
    return CashierErrorModel(
      message: 'Failed to remove item from cart. Please try again.',
      code: 'remove_from_cart_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to clear cart
  factory CashierErrorModel.clearCartFailed() {
    return CashierErrorModel(
      message: 'Failed to clear cart. Please try again.',
      code: 'clear_cart_failed',
      statusCode: 500,
    );
  }

  /// Error when item already in cart
  factory CashierErrorModel.itemAlreadyInCart() {
    return CashierErrorModel(
      message: 'Item is already in cart',
      code: 'item_already_in_cart',
      statusCode: 409,
    );
  }

  /// Error when maximum quantity reached
  factory CashierErrorModel.maxQuantityReached() {
    return CashierErrorModel(
      message: 'Maximum quantity reached for this item',
      code: 'max_quantity_reached',
      statusCode: 400,
    );
  }

  // ==================== Checkout Errors ====================

  /// Error when payment method not selected
  factory CashierErrorModel.paymentMethodNotSelected() {
    return CashierErrorModel(
      message: 'Please select a payment method',
      code: 'payment_method_not_selected',
      statusCode: 400,
    );
  }

  /// Error when checkout failed
  factory CashierErrorModel.checkoutFailed() {
    return CashierErrorModel(
      message: 'Checkout failed. Please try again.',
      code: 'checkout_failed',
      statusCode: 500,
    );
  }

  /// Error when payment processing failed
  factory CashierErrorModel.paymentProcessingFailed() {
    return CashierErrorModel(
      message: 'Payment processing failed. Please try again.',
      code: 'payment_processing_failed',
      statusCode: 500,
    );
  }

  /// Error when insufficient payment
  factory CashierErrorModel.insufficientPayment() {
    return CashierErrorModel(
      message: 'Payment amount is less than the total',
      code: 'insufficient_payment',
      statusCode: 400,
    );
  }

  /// Error when transaction failed
  factory CashierErrorModel.transactionFailed() {
    return CashierErrorModel(
      message: 'Transaction failed. Please try again.',
      code: 'transaction_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to generate receipt
  factory CashierErrorModel.generateReceiptFailed() {
    return CashierErrorModel(
      message: 'Failed to generate receipt. Please try again.',
      code: 'generate_receipt_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to print receipt
  factory CashierErrorModel.printReceiptFailed() {
    return CashierErrorModel(
      message: 'Failed to print receipt. Please try again.',
      code: 'print_receipt_failed',
      statusCode: 500,
    );
  }

  // ==================== Order Errors ====================

  /// Error when order not found
  factory CashierErrorModel.orderNotFound() {
    return CashierErrorModel(
      message: 'Order not found',
      code: 'order_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to create order
  factory CashierErrorModel.createOrderFailed() {
    return CashierErrorModel(
      message: 'Failed to create order. Please try again.',
      code: 'create_order_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update order
  factory CashierErrorModel.updateOrderFailed() {
    return CashierErrorModel(
      message: 'Failed to update order. Please try again.',
      code: 'update_order_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to cancel order
  factory CashierErrorModel.cancelOrderFailed() {
    return CashierErrorModel(
      message: 'Failed to cancel order. Please try again.',
      code: 'cancel_order_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to load orders
  factory CashierErrorModel.failedLoadOrders() {
    return CashierErrorModel(
      message: 'Failed to load orders. Please try again.',
      code: 'failed_load_orders',
      statusCode: 500,
    );
  }

  /// Error when order already completed
  factory CashierErrorModel.orderAlreadyCompleted() {
    return CashierErrorModel(
      message: 'Order is already completed',
      code: 'order_already_completed',
      statusCode: 400,
    );
  }

  /// Error when order already cancelled
  factory CashierErrorModel.orderAlreadyCancelled() {
    return CashierErrorModel(
      message: 'Order is already cancelled',
      code: 'order_already_cancelled',
      statusCode: 400,
    );
  }

  /// Error when failed to update order status
  factory CashierErrorModel.updateOrderStatusFailed() {
    return CashierErrorModel(
      message: 'Failed to update order status. Please try again.',
      code: 'update_order_status_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid order status
  factory CashierErrorModel.invalidOrderStatus() {
    return CashierErrorModel(
      message: 'Invalid order status',
      code: 'invalid_order_status',
      statusCode: 400,
    );
  }

  // ==================== Table Errors ====================

  /// Error when table not found
  factory CashierErrorModel.tableNotFound() {
    return CashierErrorModel(
      message: 'Table not found',
      code: 'table_not_found',
      statusCode: 404,
    );
  }

  /// Error when table is not available
  factory CashierErrorModel.tableNotAvailable() {
    return CashierErrorModel(
      message: 'Table is not available. Please select another table.',
      code: 'table_not_available',
      statusCode: 409,
    );
  }

  /// Error when table is already occupied
  factory CashierErrorModel.tableAlreadyOccupied() {
    return CashierErrorModel(
      message: 'Table is already occupied',
      code: 'table_already_occupied',
      statusCode: 409,
    );
  }

  /// Error when failed to load tables
  factory CashierErrorModel.failedLoadTables() {
    return CashierErrorModel(
      message: 'Failed to load tables. Please try again.',
      code: 'failed_load_tables',
      statusCode: 500,
    );
  }

  /// Error when failed to update table status
  factory CashierErrorModel.updateTableStatusFailed() {
    return CashierErrorModel(
      message: 'Failed to update table status. Please try again.',
      code: 'update_table_status_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid table selection
  factory CashierErrorModel.invalidTableSelection() {
    return CashierErrorModel(
      message: 'Invalid table selection',
      code: 'invalid_table_selection',
      statusCode: 400,
    );
  }

  // ==================== Report Errors ====================

  /// Error when failed to load reports
  factory CashierErrorModel.failedLoadReports() {
    return CashierErrorModel(
      message: 'Failed to load reports. Please try again.',
      code: 'failed_load_reports',
      statusCode: 500,
    );
  }

  /// Error when failed to generate report
  factory CashierErrorModel.generateReportFailed() {
    return CashierErrorModel(
      message: 'Failed to generate report. Please try again.',
      code: 'generate_report_failed',
      statusCode: 500,
    );
  }

  /// Error when no data available for report
  factory CashierErrorModel.noReportData() {
    return CashierErrorModel(
      message: 'No data available for the selected period',
      code: 'no_report_data',
      statusCode: 404,
    );
  }

  /// Error when failed to export report
  factory CashierErrorModel.exportReportFailed() {
    return CashierErrorModel(
      message: 'Failed to export report. Please try again.',
      code: 'export_report_failed',
      statusCode: 500,
    );
  }

  // ==================== Settings Errors ====================

  /// Error when failed to load settings
  factory CashierErrorModel.failedLoadSettings() {
    return CashierErrorModel(
      message: 'Failed to load settings. Please try again.',
      code: 'failed_load_settings',
      statusCode: 500,
    );
  }

  /// Error when failed to update settings
  factory CashierErrorModel.updateSettingsFailed() {
    return CashierErrorModel(
      message: 'Failed to update settings. Please try again.',
      code: 'update_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid configuration value
  factory CashierErrorModel.invalidConfiguration() {
    return CashierErrorModel(
      message: 'Invalid configuration value',
      code: 'invalid_configuration',
      statusCode: 400,
    );
  }

  // ==================== Product Errors ====================

  /// Error when product not found
  factory CashierErrorModel.productNotFound() {
    return CashierErrorModel(
      message: 'Product not found',
      code: 'product_not_found',
      statusCode: 404,
    );
  }

  /// Error when product out of stock
  factory CashierErrorModel.productOutOfStock() {
    return CashierErrorModel(
      message: 'Product is out of stock',
      code: 'product_out_of_stock',
      statusCode: 400,
    );
  }

  /// Error when failed to load products
  factory CashierErrorModel.failedLoadProducts() {
    return CashierErrorModel(
      message: 'Failed to load products. Please try again.',
      code: 'failed_load_products',
      statusCode: 500,
    );
  }

  /// Error when insufficient stock
  factory CashierErrorModel.insufficientStock() {
    return CashierErrorModel(
      message: 'Insufficient stock available',
      code: 'insufficient_stock',
      statusCode: 400,
    );
  }

  // ==================== Network & Server Errors ====================

  /// Error when network connection is unavailable
  factory CashierErrorModel.networkError() {
    return CashierErrorModel(
      message:
          'A network error occurred. Please check your internet connection.',
      code: 'network_error',
      statusCode: null,
    );
  }

  /// Error when request times out
  factory CashierErrorModel.requestTimeOut() {
    return CashierErrorModel(
      message: 'The request timed out. Please try again later.',
      code: 'timeout',
      statusCode: 408,
    );
  }

  /// Error when server encounters an internal error
  factory CashierErrorModel.internalServer() {
    return CashierErrorModel(
      message: 'An internal server error occurred. Please try again later.',
      code: 'internal_server_error',
      statusCode: 500,
    );
  }

  /// Error when an unknown error occurs
  factory CashierErrorModel.unknownError() {
    return CashierErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  // ==================== Permission Errors ====================

  /// Error when user doesn't have permission
  factory CashierErrorModel.permissionDenied() {
    return CashierErrorModel(
      message: 'You do not have permission to perform this action.',
      code: 'permission_denied',
      statusCode: 403,
    );
  }

  /// Error when unauthorized access
  factory CashierErrorModel.unauthorized() {
    return CashierErrorModel(
      message: 'Unauthorized access. Please log in again.',
      code: 'unauthorized',
      statusCode: 401,
    );
  }
}
