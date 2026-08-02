/// نوع الخصم: نسبة مئوية أو مبلغ ثابت.
enum CouponType { percent, fixed }

class Coupon {
  const Coupon({
    required this.code,
    required this.type,
    required this.value,
    this.minOrder = 0,
    this.active = true,
  });

  final String code;
  final CouponType type;
  final double value;
  final double minOrder;
  final bool active;

  /// يحسب قيمة الخصم على مبلغ معين.
  double discountFor(double subtotal) {
    if (!active || subtotal < minOrder) return 0;
    final amount =
        type == CouponType.percent ? subtotal * (value / 100) : value;
    return amount > subtotal ? subtotal : amount;
  }

  String get label => type == CouponType.percent
      ? 'خصم ${value.toStringAsFixed(0)}%'
      : 'خصم ${value.toStringAsFixed(0)} ج.م';

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        code: json['code'] as String,
        type: json['type'] == 'fixed' ? CouponType.fixed : CouponType.percent,
        value: (json['value'] as num).toDouble(),
        minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0,
        active: json['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'type': type == CouponType.fixed ? 'fixed' : 'percent',
        'value': value,
        'minOrder': minOrder,
        'active': active,
      };
}

/// أكواد الخصم المتاحة (تجريبية — استبدلها بجدول من الـ API لاحقاً).
class CouponStore {
  CouponStore._();

  static final List<Coupon> coupons = [
    const Coupon(code: 'ANAQA10', type: CouponType.percent, value: 10),
    const Coupon(
      code: 'SAVE100',
      type: CouponType.fixed,
      value: 100,
      minOrder: 1000,
    ),
    const Coupon(code: 'FIRST15', type: CouponType.percent, value: 15),
  ];

  /// يدوّر على كود ويرجّعه لو صالح، وإلا null.
  static Coupon? find(String code) {
    final normalized = code.trim().toUpperCase();
    for (final c in coupons) {
      if (c.code == normalized && c.active) return c;
    }
    return null;
  }
}
