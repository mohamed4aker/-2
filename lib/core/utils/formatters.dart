/// تنسيق السعر بالجنيه المصري.
String formatPrice(double value) {
  final isWhole = value == value.roundToDouble();
  final text = isWhole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  return '$text ج.م';
}

/// تنسيق التاريخ والوقت بشكل مبسط.
String formatDate(DateTime date) {
  final d = date.toLocal();
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'م' : 'ص';
  return '${d.day}/${d.month}/${d.year} - $hour12:$minute $period';
}

/// تاريخ فقط بدون وقت.
String formatDay(DateTime date) {
  final d = date.toLocal();
  return '${d.day}/${d.month}/${d.year}';
}
