extension StringX on String {
  bool get isEmail {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(this);
  }

  bool get isNumeric => double.tryParse(this) != null;

  bool get isNotNullOrEmpty => trim().isNotEmpty;
}
