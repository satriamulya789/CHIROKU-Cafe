enum UserRole {
  admin,
  cashier,
}

extension UserRoleExt on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.cashier:
        return 'cashier';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.cashier,
    );
  }
}

enum OrderStatus {
  pending,
  paid,
  cancelled,
}

extension OrderStatusExt on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.paid:
        return 'paid';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum DiscountType {
  fixed,
  percent,
}

extension DiscountTypeExt on DiscountType {
  String get value {
    switch (this) {
      case DiscountType.fixed:
        return 'fixed';
      case DiscountType.percent:
        return 'percent';
    }
  }

  static DiscountType fromString(String value) {
    return DiscountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DiscountType.fixed,
    );
  }
}

enum PaymentMethod {
  cash,
  qris,
  card,
  ewallet,
}

extension PaymentMethodExt on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.ewallet:
        return 'ewallet';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
