/// نوع الإشعار — بيحدد الأيقونة والسلوك عند الضغط.
enum NotificationType { newProduct, offer, orderStatus, reminder, general }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.productId,
    this.orderId,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;

  /// لو الإشعار عن منتج معين، الضغط عليه يفتح صفحته.
  final String? productId;
  final String? orderId;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        read: read ?? this.read,
        productId: productId,
        orderId: orderId,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.general,
        ),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        read: json['read'] as bool? ?? false,
        productId: json['productId'] as String?,
        orderId: json['orderId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
        'productId': productId,
        'orderId': orderId,
      };
}
