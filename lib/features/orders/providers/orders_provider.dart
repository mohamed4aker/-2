import 'package:flutter/foundation.dart';

import '../../cart/data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/order_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({OrderRepository? repository})
      : _repository = repository ?? MockOrderRepository();

  final OrderRepository _repository;

  List<Order> _allOrders = [];
  List<Order> _myOrders = [];
  bool _loading = false;

  List<Order> get allOrders => _allOrders;
  List<Order> get myOrders => _myOrders;
  bool get loading => _loading;

  // ---------- إحصائيات لوحة تحكم الأدمن ----------

  int get totalOrders => _allOrders.length;

  int get pendingCount =>
      _allOrders.where((o) => o.status == OrderStatus.pending).length;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// مبيعات اليوم (كل الطلبات غير الملغية التي أُنشئت اليوم).
  double get todaySales => _allOrders
      .where((o) => o.status != OrderStatus.cancelled && _isToday(o.createdAt))
      .fold(0, (sum, o) => sum + o.total);

  double get totalSales => _allOrders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0, (sum, o) => sum + o.total);

  List<Order> byStatus(OrderStatus? status) => status == null
      ? _allOrders
      : _allOrders.where((o) => o.status == status).toList();

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      _allOrders = await _repository.fetchAllOrders();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMine(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _myOrders = await _repository.fetchUserOrders(userId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Order> placeOrder({
    required String userId,
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required PaymentMethod paymentMethod,
    required List<CartItem> cartItems,
    required double total,
  }) async {
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      userId: userId,
      customerName: customerName,
      phone: phone,
      address: address,
      city: city,
      paymentMethod: paymentMethod,
      items: cartItems
          .map((c) => OrderItem(
                productId: c.product.id,
                name: c.product.name,
                image: c.product.mainImage,
                price: c.product.finalPrice,
                quantity: c.quantity,
                size: c.size,
                color: c.color,
              ))
          .toList(),
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    final created = await _repository.createOrder(order);
    _myOrders = [created, ..._myOrders];
    notifyListeners();
    return created;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repository.updateStatus(orderId, status);
    await loadAll();
  }
}
