import '../../products/data/product_repository.dart';
import 'models/order.dart';

/// واجهة مستودع الطلبات.
abstract class OrderRepository {
  Future<List<Order>> fetchAllOrders();
  Future<List<Order>> fetchUserOrders(String userId);
  Future<Order> createOrder(Order order);
  Future<Order> updateStatus(String orderId, OrderStatus status);
}

/// تنفيذ تجريبي في الذاكرة مع طلبات جاهزة لعرض لوحة تحكم الأدمن.
class MockOrderRepository implements OrderRepository {
  static final List<Order> store = _seedOrders();

  static const _delay = Duration(milliseconds: 350);

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
        items: const [
          OrderItem(
            productId: 'p1',
            name: 'حذاء كعب كلاسيك أسود',
            image: 'https://picsum.photos/seed/anaqa-heel-1/800/800?grayscale',
            price: 950,
            quantity: 1,
            size: '38',
            color: 'أسود',
          ),
          OrderItem(
            productId: 'p8',
            name: 'نظارة شمس كات آي',
            image:
                'https://picsum.photos/seed/anaqa-cateye-1/800/800?grayscale',
            price: 750,
            quantity: 1,
            color: 'أسود',
          ),
        ],
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
        paymentMethod: PaymentMethod.cashOnDelivery,
        items: const [
          OrderItem(
            productId: 'p5',
            name: 'شنطة يد جلد فاخرة',
            image: 'https://picsum.photos/seed/anaqa-bag-1/800/800?grayscale',
            price: 1480,
            quantity: 1,
            color: 'بيج',
          ),
        ],
        total: 1480,
        status: OrderStatus.confirmed,
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
        items: const [
          OrderItem(
            productId: 'p11',
            name: 'طقم إكسسوارات ذهبي',
            image: 'https://picsum.photos/seed/anaqa-set-1/800/800?grayscale',
            price: 760,
            quantity: 2,
            color: 'ذهبي',
          ),
        ],
        total: 1520,
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
        items: const [
          OrderItem(
            productId: 'p2',
            name: 'سنيكرز جلد أبيض',
            image:
                'https://picsum.photos/seed/anaqa-sneaker-1/800/800?grayscale',
            price: 1450,
            quantity: 1,
            size: '37',
            color: 'أبيض',
          ),
        ],
        total: 1450,
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
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
    return store[index];
  }
}
