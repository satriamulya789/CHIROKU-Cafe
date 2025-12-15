import 'package:chiroku_cafe/utils/enums/discount_enum.dart';
import 'package:chiroku_cafe/utils/enums/oder_enum.dart';
import 'package:chiroku_cafe/utils/enums/payment_enum.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';


// USER ROLE
extension UserRoleX on UserRole {
  bool get isAdmin => this == UserRole.admin;
  bool get isCashier => this == UserRole.cashier;
}

// ORDER STATUS
extension OrderStatusX on OrderStatus {
  bool get isPaid => this == OrderStatus.paid;
  bool get isPending => this == OrderStatus.pending;
  bool get isCancelled => this == OrderStatus.cancelled;
}

// DISCOUNT
extension DiscountTypeX on DiscountType {
  bool get isPercent => this == DiscountType.percent;
  bool get isFixed => this == DiscountType.fixed;
}

// PAYMENT
extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
    }
  }
}
