extension NumX on num {
  String get currency {
    return 'Rp ${toStringAsFixed(0)}';
  }

  num percentOf(num total) {
    return (this / 100) * total;
  }
}
