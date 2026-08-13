import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_storage.dart';
import '../../products/data/product_repository.dart';
import 'models/order.dart';

/// واجهة مستودع الطلبات.
abstract class OrderRepository {
  Future<List<Order>> fetchAllOrders();
  Future<List<Order>> fetchUserOrders(String userId);
  Future<Order> createOrder(Order order);
  Future<Order> updateStatus(String orderId, OrderStatus status);
  Future<Order> updatePayment(
    String orderId,
    PaymentStatus status,
    String? transactionId,
  );
}

/// تنفيذ تجريبي في الذاكرة مع طلبات جاهزة لعرض لوحة تحكم الأدمن.
class MockOrderRepository implements OrderRepository {
  static List<Order>? _cache;

  static const _delay = Duration(milliseconds: 350);

  /// الطلبات محفوظة على الجهاز وبتفضل بعد قفل التطبيق.
  static List<Order> get store {
    if (_cache != null) return _cache!;

    final raw = LocalStorage.getString(LocalStorage.keyOrders);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = (jsonDecode(raw) as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cache!;
      } catch (_) {
        // بيانات تالفة — نبدأ من جديد.
      }
    }

    _cache = AppConfig.useDemoData ? _seedOrders() : <Order>[];
    _persist();
    return _cache!;
  }

  static void _persist() {
    if (_cache == null) return;
    LocalStorage.setString(
      LocalStorage.keyOrders,
      jsonEncode(_cache!.map((o) => o.toJson()).toList()),
    );
  }

  /// مسح كل الطلبات (من زر تصفير البيانات).
  static Future<void> clearAll() async {
    _cache = <Order>[];
    await LocalStorage.setString(LocalStorage.keyOrders, '[]');
  }

  static String _img(String seed) =>
      'https://picsum.photos/seed/$seed/800/800?grayscale';

  static List<Order> _seedOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD-1001',
        userId: 'demo_user_1',
        customerName: 'سارة محمد',
        phone: '01011112222',
        address: '15 شارع التحرير، الدقي',
        city: 'الجيزة',
        paymentMethod: PaymentMethod.cashOnDelivery,
        items: [
          OrderItem(
            productId: 'p1',
            name: 'حذاء كعب كلاسيك أسود',
            image: _img('moda-heel-1'),
            price: 950,
            originalPrice: 1250,
            quantity: 1,
            size: '38',
            color: 'أسود',
          ),
          OrderItem(
            productId: 'p8',
            name: 'نظارة شمس كات آي',
            image: _img('moda-cateye-1'),
            price: 750,
            quantity: 1,
            color: 'أسود',
          ),
        ],
        subtotal: 1700,
        shipping: 0,
        total: 1700,
        status: OrderStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD-1002',
        userId: 'demo_user_2',
        customerName: 'منى أحمد',
        phone: '01233334444',
        address: '8 شارع فؤاد، محطة الرمل',
        city: 'الإسكندرية',
        paymentMethod: PaymentMethod.card,
        items: [
          OrderItem(
            productId: 'p5',
            name: 'شنطة يد جلد فاخرة',
            image: _img('moda-bag-1'),
            price: 1480,
            originalPrice: 1850,
            quantity: 1,
            color: 'بيج',
          ),
          OrderItem(
            productId: 'p2',
            name: 'سنيكرز جلد أبيض',
            image: _img('moda-sneaker-1'),
            price: 1450,
            quantity: 1,
            size: '38',
            color: 'أبيض',
          ),
        ],
        subtotal: 2930,
        shipping: 0,
        total: 2930,
        status: OrderStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        transactionId: 'TRX-DEMO-1002',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Order(
        id: 'ORD-1003',
        userId: 'demo_user_3',
        customerName: 'هدير علي',
        phone: '01555556666',
        address: '22 شارع الجمهورية',
        city: 'المنصورة',
        paymentMethod: PaymentMethod.cashOnDelivery,
        items: [
          OrderItem(
            productId: 'p11',
            name: 'طقم إكسسوارات ذهبي',
            image: _img('moda-set-1'),
            price: 760,
            originalPrice: 950,
            quantity: 2,
            color: 'ذهبي',
          ),
          OrderItem(
            productId: 'p5',
            name: 'شنطة يد جلد فاخرة',
            image: _img('moda-bag-1'),
            price: 1480,
            originalPrice: 1850,
            quantity: 1,
            color: 'أسود',
          ),
        ],
        subtotal: 3000,
        shipping: 0,
        discount: 300,
        couponCode: 'ANAQA10',
        total: 2700,
        status: OrderStatus.shipped,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD-1004',
        userId: 'demo_user_4',
        customerName: 'ياسمين خالد',
        phone: '01099998888',
        address: '5 شارع 9، المعادي',
        city: 'القاهرة',
        paymentMethod: PaymentMethod.cashOnDelivery,
        items: [
          OrderItem(
            productId: 'p2',
            name: 'سنيكرز جلد أبيض',
            image: _img('moda-sneaker-1'),
            price: 1450,
            quantity: 1,
            size: '37',
            color: 'أبيض',
          ),
          OrderItem(
            productId: 'p6',
            name: 'شنطة كروس صغيرة',
            image: _img('moda-cross-1'),
            price: 890,
            quantity: 1,
            color: 'أسود',
          ),
        ],
        subtotal: 2340,
        shipping: 0,
        total: 2340,
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Order(
        id: 'ORD-1005',
        userId: 'demo_user_5',
        customerName: 'نورهان سمير',
        phone: '01277778888',
        address: '30 شارع الهرم',
        city: 'الجيزة',
        paymentMethod: PaymentMethod.card,
        items: [
          OrderItem(
            productId: 'p9',
            name: 'نظارة شمس أفياتور',
            image: _img('moda-aviator-1'),
            price: 650,
            originalPrice: 820,
            quantity: 1,
            color: 'ذهبي',
          ),
          OrderItem(
            productId: 'p14',
            name: 'حلق دائري كبير',
            image: _img('moda-hoops-1'),
            price: 220,
            originalPrice: 280,
            quantity: 2,
            color: 'ذهبي',
          ),
        ],
        subtotal: 1090,
        shipping: 60,
        total: 1150,
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.paid,
        transactionId: 'TRX-DEMO-1005',
        isGuestOrder: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<Order>> fetchAllOrders() async {
    await Future.delayed(_delay);
    final list = List.of(store);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Order>> fetchUserOrders(String userId) async {
    await Future.delayed(_delay);
    final list = store.where((o) => o.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future.delayed(_delay);
    store.add(order);
    _persist();
    // خصم الكميات من المخزون (سلوك تجريبي فقط، الباك اند الحقيقي يتكفل بهذا).
    for (final item in order.items) {
      MockProductRepository.decreaseStock(item.productId, item.quantity);
    }
    return order;
  }

  @override
  Future<Order> updateStatus(String orderId, OrderStatus status) async {
    await Future.delayed(_delay);
    final index = store.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('الطلب غير موجود');
    }
    store[index] = store[index].copyWith(status: status);
    _persist();
    return store[index];
  }

  @override
  Future<Order> updatePayment(
    String orderId,
    PaymentStatus status,
    String? transactionId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = store.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('الطلب غير موجود');
    }
    store[index] = store[index].copyWith(
      paymentStatus: status,
      transactionId: transactionId,
    );
    _persist();
    return store[index];
  }
}
