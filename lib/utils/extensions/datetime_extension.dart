extension DateTimeX on DateTime {
  String get toDate {
    return '${day.toString().padLeft(2, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '$year';
  }

  String get toTime {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
