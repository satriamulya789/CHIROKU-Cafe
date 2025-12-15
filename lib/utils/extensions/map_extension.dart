extension MapX on Map<String, dynamic> {
  T getOrDefault<T>(String key, T defaultValue) {
    final value = this[key];
    if (value is T) return value;
    return defaultValue;
  }
}

extension JsonListX on List {
  List<Map<String, dynamic>> get asJsonList =>
      cast<Map<String, dynamic>>();
}
