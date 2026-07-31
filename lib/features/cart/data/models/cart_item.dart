import '../../../products/data/models/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.size,
    this.color,
  });

  final Product product;
  final int quantity;
  final String? size;
  final String? color;

  /// مفتاح فريد للمنتج مع اختياراته (مقاس/لون).
  String get key => '${product.id}|${size ?? ''}|${color ?? ''}';

  double get total => product.finalPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        size: size,
        color: color,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        quantity: (json['quantity'] as num).toInt(),
        size: json['size'] as String?,
        color: json['color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'size': size,
        'color': color,
      };
}
