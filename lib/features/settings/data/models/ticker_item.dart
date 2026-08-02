/// نوع عنصر الشريط المتحرك: نص أو صورة.
enum TickerType { text, image }

/// عنصر واحد في الشريط المتحرك (اللي بيلف في أعلى الصفحة الرئيسية).
class TickerItem {
  const TickerItem({
    required this.id,
    required this.type,
    required this.value,
    this.enabled = true,
  });

  final String id;
  final TickerType type;

  /// النص المكتوب، أو مسار/رابط الصورة حسب [type].
  final String value;
  final bool enabled;

  TickerItem copyWith({String? value, bool? enabled}) => TickerItem(
        id: id,
        type: type,
        value: value ?? this.value,
        enabled: enabled ?? this.enabled,
      );

  factory TickerItem.fromJson(Map<String, dynamic> json) => TickerItem(
        id: json['id'] as String,
        type: json['type'] == 'image' ? TickerType.image : TickerType.text,
        value: json['value'] as String,
        enabled: json['enabled'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == TickerType.image ? 'image' : 'text',
        'value': value,
        'enabled': enabled,
      };
}
