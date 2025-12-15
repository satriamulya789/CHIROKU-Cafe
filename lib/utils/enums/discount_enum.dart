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