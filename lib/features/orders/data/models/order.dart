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
enum PaymentMethod { cashOnDelivery, card }

extension PaymentMethodX on PaymentMethod {
  String get labelAr => switch (this) {
        PaymentMethod.cashOnDelivery => 'الدفع عند الاستلام',
        PaymentMethod.card => 'بطاقة بنكية (فيزا / ماستركارد)',
      };
}

/// حالة الدفع.
enum PaymentStatus { pending, paid, failed }

extension PaymentStatusX on PaymentStatus {
  String get labelAr => switch (this) {
        PaymentStatus.pending => 'في انتظار الدفع',
        PaymentStatus.paid => 'مدفوع',
        PaymentStatus.failed => 'فشل الدفع',
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
    this.originalPrice,
    this.size,
    this.color,
  });

  final String productId;
  final String name;
  final String image;

  /// السعر المدفوع فعلياً (بعد الخصم).
  final double price;

  /// السعر قبل الخصم — بيظهر مشطوب في الإيصال.
  final double? originalPrice;
  final int quantity;
  final String? size;
  final String? color;

  double get total => price * quantity;

  bool get hadDiscount => originalPrice != null && originalPrice! > price;

  double get savedAmount =>
      hadDiscount ? (originalPrice! - price) * quantity : 0;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        image: json['image'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num?)?.toDouble(),
        quantity: (json['quantity'] as num).toInt(),
        size: json['size'] as String?,
        color: json['color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'image': image,
        'price': price,
        'originalPrice': originalPrice,
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
    required this.subtotal,
    required this.shipping,
    this.discount = 0,
    this.couponCode,
    required this.total,
    required this.status,
    this.paymentStatus = PaymentStatus.pending,
    this.transactionId,
    this.isGuestOrder = false,
    this.notes,
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

  final double subtotal;
  final double shipping;
  final double discount;
  final String? couponCode;
  final double total;

  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? transactionId;
  final bool isGuestOrder;
  final String? notes;
  final DateTime createdAt;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// إجمالي ما وفّره العميل (خصومات المنتجات + الكوبون).
  double get totalSaved =>
      items.fold<double>(0, (sum, i) => sum + i.savedAmount) + discount;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? transactionId,
  }) =>
      Order(
        id: id,
        userId: userId,
        customerName: customerName,
        phone: phone,
        address: address,
        city: city,
        paymentMethod: paymentMethod,
        items: items,
        subtotal: subtotal,
        shipping: shipping,
        discount: discount,
        couponCode: couponCode,
        total: total,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        transactionId: transactionId ?? this.transactionId,
        isGuestOrder: isGuestOrder,
        notes: notes,
        createdAt: createdAt,
      );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        customerName: json['customerName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        paymentMethod: json['paymentMethod'] == 'card'
            ? PaymentMethod.card
            : PaymentMethod.cashOnDelivery,
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num?)?.toDouble() ??
            (json['total'] as num).toDouble(),
        shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        couponCode: json['couponCode'] as String?,
        total: (json['total'] as num).toDouble(),
        status: OrderStatusX.fromName(json['status'] as String? ?? 'pending'),
        paymentStatus: PaymentStatus.values.firstWhere(
          (p) => p.name == json['paymentStatus'],
          orElse: () => PaymentStatus.pending,
        ),
        transactionId: json['transactionId'] as String?,
        isGuestOrder: json['isGuestOrder'] as bool? ?? false,
        notes: json['notes'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
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
            paymentMethod == PaymentMethod.card ? 'card' : 'cod',
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'shipping': shipping,
        'discount': discount,
        'couponCode': couponCode,
        'total': total,
        'status': status.name,
        'paymentStatus': paymentStatus.name,
        'transactionId': transactionId,
        'isGuestOrder': isGuestOrder,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
