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
