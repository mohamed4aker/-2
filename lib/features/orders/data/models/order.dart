/// حالات الطلب.
enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get labelAr => switch (this) {
        OrderStatus.pending => 'جديد',
        OrderStatus.confirmed => 'تم التأكيد',
        OrderStatus.shipped => 'تم الشحن',
        OrderStatus.delivered => 'تم التسليم',
        OrderStatus.cancelled => 'ملغي',
      };

  static OrderStatus fromName(String name) => OrderStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => OrderStatus.pending,
      );
}

/// طرق الدفع.
enum PaymentMethod { cashOnDelivery, online }

extension PaymentMethodX on PaymentMethod {
  String get labelAr => switch (this) {
        PaymentMethod.cashOnDelivery => 'الدفع عند الاستلام',
        PaymentMethod.online => 'دفع إلكتروني (قريباً)',
      };
}

/// عنصر داخل الطلب (لقطة من المنتج وقت الشراء).
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
  });

  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String? size;
  final String? color;

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        image: json['image'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
        size: json['size'] as String?,
        color: json['color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'image': image,
        'price': price,
        'quantity': quantity,
        'size': size,
        'color': color,
      };
}

class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.paymentMethod,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final String city;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        userId: userId,
        customerName: customerName,
        phone: phone,
        address: address,
        city: city,
        paymentMethod: paymentMethod,
        items: items,
        total: total,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        customerName: json['customerName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        paymentMethod: json['paymentMethod'] == 'online'
            ? PaymentMethod.online
            : PaymentMethod.cashOnDelivery,
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
        status: OrderStatusX.fromName(json['status'] as String? ?? 'pending'),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'city': city,
        'paymentMethod':
            paymentMethod == PaymentMethod.online ? 'online' : 'cod',
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
