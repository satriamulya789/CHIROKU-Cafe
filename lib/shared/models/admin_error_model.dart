class AdminErrorModel {
  final String message;
  final String code;
  final int? statusCode;

  AdminErrorModel({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  // ==================== Validation Errors ====================

  /// Error when discount name field is empty
  factory AdminErrorModel.discountNameEmpty() {
    return AdminErrorModel(
      message: 'Discount name must not be empty',
      code: 'discount_name_empty',
      statusCode: 400,
    );
  }

  /// Error when discount value is invalid
  factory AdminErrorModel.invalidDiscountValue() {
    return AdminErrorModel(
      message: 'Discount value must be greater than 0',
      code: 'invalid_discount_value',
      statusCode: 400,
    );
  }

  /// Error when discount percentage exceeds 100
  factory AdminErrorModel.discountPercentageTooHigh() {
    return AdminErrorModel(
      message: 'Discount percentage cannot exceed 100%',
      code: 'discount_percentage_too_high',
      statusCode: 400,
    );
  }

  /// Error when product name is empty
  factory AdminErrorModel.productNameEmpty() {
    return AdminErrorModel(
      message: 'Product name must not be empty',
      code: 'product_name_empty',
      statusCode: 400,
    );
  }

  /// Error when product price is invalid
  factory AdminErrorModel.invalidProductPrice() {
    return AdminErrorModel(
      message: 'Product price must be greater than 0',
      code: 'invalid_product_price',
      statusCode: 400,
    );
  }

  /// Error when category name is empty
  factory AdminErrorModel.categoryNameEmpty() {
    return AdminErrorModel(
      message: 'Category name must not be empty',
      code: 'category_name_empty',
      statusCode: 400,
    );
  }

  /// Error when stock quantity is invalid
  factory AdminErrorModel.invalidStockQuantity() {
    return AdminErrorModel(
      message: 'Stock quantity must be a valid number',
      code: 'invalid_stock_quantity',
      statusCode: 400,
    );
  }

  /// Error when date range is invalid
  factory AdminErrorModel.invalidDateRange() {
    return AdminErrorModel(
      message: 'Invalid date range. End date must be after start date',
      code: 'invalid_date_range',
      statusCode: 400,
    );
  }

  /// Error when printer name is empty
  factory AdminErrorModel.printerNameEmpty() {
    return AdminErrorModel(
      message: 'Printer name must not be empty',
      code: 'printer_name_empty',
      statusCode: 400,
    );
  }

  /// Error when QRIS merchant ID is empty
  factory AdminErrorModel.qrisMerchantIdEmpty() {
    return AdminErrorModel(
      message: 'QRIS Merchant ID must not be empty',
      code: 'qris_merchant_id_empty',
      statusCode: 400,
    );
  }

  // ==================== Discount Management Errors ====================

  /// Error when discount already exists
  factory AdminErrorModel.discountAlreadyExists() {
    return AdminErrorModel(
      message: 'A discount with this name already exists',
      code: 'discount_already_exists',
      statusCode: 409,
    );
  }

  /// Error when failed to create discount
  factory AdminErrorModel.createDiscountFailed() {
    return AdminErrorModel(
      message: 'Failed to create discount. Please try again.',
      code: 'create_discount_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update discount
  factory AdminErrorModel.updateDiscountFailed() {
    return AdminErrorModel(
      message: 'Failed to update discount. Please try again.',
      code: 'update_discount_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to delete discount
  factory AdminErrorModel.deleteDiscountFailed() {
    return AdminErrorModel(
      message: 'Failed to delete discount. Please try again.',
      code: 'delete_discount_failed',
      statusCode: 500,
    );
  }

  /// Error when discount not found
  factory AdminErrorModel.discountNotFound() {
    return AdminErrorModel(
      message: 'Discount not found',
      code: 'discount_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to load discounts
  factory AdminErrorModel.failedLoadDiscounts() {
    return AdminErrorModel(
      message: 'Failed to load discounts. Please try again.',
      code: 'failed_load_discounts',
      statusCode: 500,
    );
  }

  // ==================== Dashboard Errors ====================

  /// Error when failed to load dashboard data
  factory AdminErrorModel.failedLoadDashboard() {
    return AdminErrorModel(
      message: 'Failed to load dashboard data. Please try again.',
      code: 'failed_load_dashboard',
      statusCode: 500,
    );
  }

  /// Error when failed to load statistics
  factory AdminErrorModel.failedLoadStatistics() {
    return AdminErrorModel(
      message: 'Failed to load statistics. Please try again.',
      code: 'failed_load_statistics',
      statusCode: 500,
    );
  }

  /// Error when failed to load recent orders
  factory AdminErrorModel.failedLoadRecentOrders() {
    return AdminErrorModel(
      message: 'Failed to load recent orders. Please try again.',
      code: 'failed_load_recent_orders',
      statusCode: 500,
    );
  }

  // ==================== Product/Menu Management Errors ====================

  /// Error when product already exists
  factory AdminErrorModel.productAlreadyExists() {
    return AdminErrorModel(
      message: 'A product with this name already exists',
      code: 'product_already_exists',
      statusCode: 409,
    );
  }

  /// Error when failed to create product
  factory AdminErrorModel.createProductFailed() {
    return AdminErrorModel(
      message: 'Failed to create product. Please try again.',
      code: 'create_product_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update product
  factory AdminErrorModel.updateProductFailed() {
    return AdminErrorModel(
      message: 'Failed to update product. Please try again.',
      code: 'update_product_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to delete product
  factory AdminErrorModel.deleteProductFailed() {
    return AdminErrorModel(
      message: 'Failed to delete product. Please try again.',
      code: 'delete_product_failed',
      statusCode: 500,
    );
  }

  /// Error when product not found
  factory AdminErrorModel.productNotFound() {
    return AdminErrorModel(
      message: 'Product not found',
      code: 'product_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to load products
  factory AdminErrorModel.failedLoadProducts() {
    return AdminErrorModel(
      message: 'Failed to load products. Please try again.',
      code: 'failed_load_products',
      statusCode: 500,
    );
  }

  // ==================== Category Management Errors ====================

  /// Error when category already exists
  factory AdminErrorModel.categoryAlreadyExists() {
    return AdminErrorModel(
      message: 'A category with this name already exists',
      code: 'category_already_exists',
      statusCode: 409,
    );
  }

  /// Error when failed to create category
  factory AdminErrorModel.createCategoryFailed() {
    return AdminErrorModel(
      message: 'Failed to create category. Please try again.',
      code: 'create_category_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update category
  factory AdminErrorModel.updateCategoryFailed() {
    return AdminErrorModel(
      message: 'Failed to update category. Please try again.',
      code: 'update_category_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to delete category
  factory AdminErrorModel.deleteCategoryFailed() {
    return AdminErrorModel(
      message: 'Failed to delete category. Please try again.',
      code: 'delete_category_failed',
      statusCode: 500,
    );
  }

  /// Error when category not found
  factory AdminErrorModel.categoryNotFound() {
    return AdminErrorModel(
      message: 'Category not found',
      code: 'category_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to load categories
  factory AdminErrorModel.failedLoadCategories() {
    return AdminErrorModel(
      message: 'Failed to load categories. Please try again.',
      code: 'failed_load_categories',
      statusCode: 500,
    );
  }

  // ==================== Inventory Management Errors ====================

  /// Error when failed to update stock
  factory AdminErrorModel.updateStockFailed() {
    return AdminErrorModel(
      message: 'Failed to update stock. Please try again.',
      code: 'update_stock_failed',
      statusCode: 500,
    );
  }

  /// Error when stock is insufficient
  factory AdminErrorModel.insufficientStock() {
    return AdminErrorModel(
      message: 'Insufficient stock available',
      code: 'insufficient_stock',
      statusCode: 400,
    );
  }

  /// Error when failed to load inventory
  factory AdminErrorModel.failedLoadInventory() {
    return AdminErrorModel(
      message: 'Failed to load inventory. Please try again.',
      code: 'failed_load_inventory',
      statusCode: 500,
    );
  }

  // ==================== Report Errors ====================

  /// Error when failed to load reports
  factory AdminErrorModel.failedLoadReports() {
    return AdminErrorModel(
      message: 'Failed to load reports. Please try again.',
      code: 'failed_load_reports',
      statusCode: 500,
    );
  }

  /// Error when failed to generate report
  factory AdminErrorModel.generateReportFailed() {
    return AdminErrorModel(
      message: 'Failed to generate report. Please try again.',
      code: 'generate_report_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to export report
  factory AdminErrorModel.exportReportFailed() {
    return AdminErrorModel(
      message: 'Failed to export report. Please try again.',
      code: 'export_report_failed',
      statusCode: 500,
    );
  }

  /// Error when no data available for report
  factory AdminErrorModel.noReportData() {
    return AdminErrorModel(
      message: 'No data available for the selected period',
      code: 'no_report_data',
      statusCode: 404,
    );
  }

  // ==================== Settings Errors ====================

  /// Error when failed to load settings
  factory AdminErrorModel.failedLoadSettings() {
    return AdminErrorModel(
      message: 'Failed to load settings. Please try again.',
      code: 'failed_load_settings',
      statusCode: 500,
    );
  }

  /// Error when failed to update settings
  factory AdminErrorModel.updateSettingsFailed() {
    return AdminErrorModel(
      message: 'Failed to update settings. Please try again.',
      code: 'update_settings_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid configuration value
  factory AdminErrorModel.invalidConfiguration() {
    return AdminErrorModel(
      message: 'Invalid configuration value',
      code: 'invalid_configuration',
      statusCode: 400,
    );
  }

  // ==================== Printer Management Errors ====================

  /// Error when printer not found
  factory AdminErrorModel.printerNotFound() {
    return AdminErrorModel(
      message: 'Printer not found',
      code: 'printer_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to connect to printer
  factory AdminErrorModel.printerConnectionFailed() {
    return AdminErrorModel(
      message: 'Failed to connect to printer. Please check the connection.',
      code: 'printer_connection_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to add printer
  factory AdminErrorModel.addPrinterFailed() {
    return AdminErrorModel(
      message: 'Failed to add printer. Please try again.',
      code: 'add_printer_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update printer
  factory AdminErrorModel.updatePrinterFailed() {
    return AdminErrorModel(
      message: 'Failed to update printer. Please try again.',
      code: 'update_printer_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to delete printer
  factory AdminErrorModel.deletePrinterFailed() {
    return AdminErrorModel(
      message: 'Failed to delete printer. Please try again.',
      code: 'delete_printer_failed',
      statusCode: 500,
    );
  }

  /// Error when printer is offline
  factory AdminErrorModel.printerOffline() {
    return AdminErrorModel(
      message: 'Printer is offline. Please check the printer status.',
      code: 'printer_offline',
      statusCode: 503,
    );
  }

  /// Error when failed to print
  factory AdminErrorModel.printFailed() {
    return AdminErrorModel(
      message: 'Failed to print. Please try again.',
      code: 'print_failed',
      statusCode: 500,
    );
  }

  // ==================== QRIS Management Errors ====================

  /// Error when QRIS configuration not found
  factory AdminErrorModel.qrisNotFound() {
    return AdminErrorModel(
      message: 'QRIS configuration not found',
      code: 'qris_not_found',
      statusCode: 404,
    );
  }

  /// Error when failed to setup QRIS
  factory AdminErrorModel.setupQrisFailed() {
    return AdminErrorModel(
      message: 'Failed to setup QRIS. Please try again.',
      code: 'setup_qris_failed',
      statusCode: 500,
    );
  }

  /// Error when failed to update QRIS
  factory AdminErrorModel.updateQrisFailed() {
    return AdminErrorModel(
      message: 'Failed to update QRIS configuration. Please try again.',
      code: 'update_qris_failed',
      statusCode: 500,
    );
  }

  /// Error when invalid QRIS merchant ID
  factory AdminErrorModel.invalidQrisMerchantId() {
    return AdminErrorModel(
      message: 'Invalid QRIS Merchant ID format',
      code: 'invalid_qris_merchant_id',
      statusCode: 400,
    );
  }

  /// Error when QRIS verification failed
  factory AdminErrorModel.qrisVerificationFailed() {
    return AdminErrorModel(
      message: 'QRIS verification failed. Please check your credentials.',
      code: 'qris_verification_failed',
      statusCode: 401,
    );
  }

  // ==================== Profile Edit Errors ====================

  /// Error when failed to update admin profile
  factory AdminErrorModel.updateAdminProfileFailed() {
    return AdminErrorModel(
      message: 'Failed to update profile. Please try again.',
      code: 'update_admin_profile_failed',
      statusCode: 500,
    );
  }

  /// Error when phone number is invalid
  factory AdminErrorModel.invalidPhoneNumber() {
    return AdminErrorModel(
      message: 'Invalid phone number format',
      code: 'invalid_phone_number',
      statusCode: 400,
    );
  }

  // ==================== Image Upload Errors ====================

  /// Error when image upload fails
  factory AdminErrorModel.uploadImageFailed() {
    return AdminErrorModel(
      message: 'Failed to upload image. Please try again.',
      code: 'upload_image_failed',
      statusCode: 500,
    );
  }

  /// Error when image format is invalid
  factory AdminErrorModel.invalidImageFormat() {
    return AdminErrorModel(
      message: 'Invalid image format. Please upload a valid image file.',
      code: 'invalid_image_format',
      statusCode: 400,
    );
  }

  /// Error when image size is too large
  factory AdminErrorModel.imageSizeTooLarge() {
    return AdminErrorModel(
      message: 'Image size is too large. Maximum size is 5MB.',
      code: 'image_size_too_large',
      statusCode: 400,
    );
  }

  // ==================== Network & Server Errors ====================

  /// Error when network connection is unavailable
  factory AdminErrorModel.networkError() {
    return AdminErrorModel(
      message:
          'A network error occurred. Please check your internet connection.',
      code: 'network_error',
      statusCode: null,
    );
  }

  /// Error when request times out
  factory AdminErrorModel.requestTimeOut() {
    return AdminErrorModel(
      message: 'The request timed out. Please try again later.',
      code: 'timeout',
      statusCode: 408,
    );
  }

  /// Error when server encounters an internal error
  factory AdminErrorModel.internalServer() {
    return AdminErrorModel(
      message: 'An internal server error occurred. Please try again later.',
      code: 'internal_server_error',
      statusCode: 500,
    );
  }

  /// Error when an unknown error occurs
  factory AdminErrorModel.unknownError() {
    return AdminErrorModel(
      message: 'An unknown error occurred. Please try again later.',
      code: 'unknown_error',
      statusCode: null,
    );
  }

  // ==================== Permission Errors ====================

  /// Error when user doesn't have permission
  factory AdminErrorModel.permissionDenied() {
    return AdminErrorModel(
      message: 'You do not have permission to perform this action.',
      code: 'permission_denied',
      statusCode: 403,
    );
  }

  /// Error when unauthorized access
  factory AdminErrorModel.unauthorized() {
    return AdminErrorModel(
      message: 'Unauthorized access. Please log in again.',
      code: 'unauthorized',
      statusCode: 401,
    );
  }
}
