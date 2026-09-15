import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/di/repository_factory.dart';
import '../../cart/data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/order_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({OrderRepository? repository})
      : _repository = repository ?? RepositoryFactory.orders();

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

  List<Order> get _valid =>
      _allOrders.where((o) => o.status != OrderStatus.cancelled).toList();

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// مبيعات اليوم (كل الطلبات غير الملغية التي أُنشئت اليوم).
  double get todaySales => _valid
      .where((o) => _isToday(o.createdAt))
      .fold(0, (sum, o) => sum + o.total);

  double get totalSales => _valid.fold(0, (sum, o) => sum + o.total);

  /// متوسط قيمة الطلب.
  double get averageOrderValue =>
      _valid.isEmpty ? 0 : totalSales / _valid.length;

  /// إجمالي تكلفة الشحن المحصّلة.
  double get totalShipping =>
      _valid.fold(0, (sum, o) => sum + o.shipping);

  /// إجمالي الخصومات الممنوحة للعملاء.
  double get totalDiscounts =>
      _valid.fold(0, (sum, o) => sum + o.totalSaved);

  /// المبالغ المحصّلة فعلياً (مدفوعة بالبطاقة أو طلبات تم تسليمها).
  double get collectedRevenue => _valid
      .where((o) => o.isPaid || o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.total);

  /// المبالغ المستحقة (لسه ما اتحصّلتش).
  double get pendingRevenue => totalSales - collectedRevenue;

  int get totalItemsSold =>
      _valid.fold(0, (sum, o) => sum + o.itemsCount);

  /// عدد العملاء الفريدين.
  int get uniqueCustomers =>
      _valid.map((o) => o.phone).toSet().length;

  List<Order> byStatus(OrderStatus? status) => status == null
      ? _allOrders
      : _allOrders.where((o) => o.status == status).toList();

  double salesSince(DateTime since) => _valid
      .where((o) => o.createdAt.isAfter(since))
      .fold(0, (sum, o) => sum + o.total);

  Order? orderById(String id) {
    for (final o in _allOrders) {
      if (o.id == id) return o;
    }
    for (final o in _myOrders) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      _allOrders = await _repository.fetchAllOrders();
      _watchAll();
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
      _watchMine(userId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ==================== التحديث الحي ====================

  StreamSubscription<List<Order>>? _allSub;
  StreamSubscription<List<Order>>? _mineSub;
  String? _watchedUserId;

  /// لوحة الأدمن بتفضل سامعة للسيرفر، فالطلب الجديد بيظهر وهو نازل
  /// من غير ما صاحب المتجر يسحب الشاشة لتحت.
  void _watchAll() {
    if (_allSub != null) return;
    final stream = _repository.watchAllOrders();
    if (stream == null) return;
    _allSub = stream.listen(
      (orders) {
        _allOrders = orders;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  /// شاشة "طلباتي" بتتحدث لوحدها لما صاحب المتجر يغيّر حالة الطلب.
  void _watchMine(String userId) {
    // لو اتغيّر المستخدم (خروج ودخول بحساب تاني) بنبدأ اشتراك جديد.
    if (_watchedUserId == userId && _mineSub != null) return;
    _mineSub?.cancel();
    _watchedUserId = userId;
    final stream = _repository.watchUserOrders(userId);
    if (stream == null) return;
    _mineSub = stream.listen(
      (orders) {
        _myOrders = orders;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _allSub?.cancel();
    _mineSub?.cancel();
    super.dispose();
  }

  Future<Order> placeOrder({
    required String userId,
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required PaymentMethod paymentMethod,
    required List<CartItem> cartItems,
    required double subtotal,
    required double shipping,
    double discount = 0,
    String? couponCode,
    required double total,
    bool isGuestOrder = false,
    String? notes,
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
                originalPrice:
                    c.product.hasDiscount ? c.product.price : null,
                quantity: c.quantity,
                size: c.size,
                color: c.color,
              ))
          .toList(),
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      couponCode: couponCode,
      total: total,
      status: OrderStatus.pending,
      isGuestOrder: isGuestOrder,
      notes: notes,
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

  /// إلغاء الطلب من ناحية العميل (مسموح فقط قبل الشحن).
  Future<bool> cancelMyOrder(String orderId) async {
    final order = orderById(orderId);
    if (order == null) return false;
    if (order.status != OrderStatus.pending &&
        order.status != OrderStatus.confirmed) {
      return false;
    }
    await _repository.updateStatus(orderId, OrderStatus.cancelled);
    _myOrders = _myOrders
        .map((o) =>
            o.id == orderId ? o.copyWith(status: OrderStatus.cancelled) : o)
        .toList();
    notifyListeners();
    return true;
  }

  Future<Order> markPaid(String orderId, String transactionId) async {
    final updated = await _repository.updatePayment(
      orderId,
      PaymentStatus.paid,
      transactionId,
    );
    _myOrders =
        _myOrders.map((o) => o.id == orderId ? updated : o).toList();
    notifyListeners();
    return updated;
  }

  Future<void> markPaymentFailed(String orderId) async {
    await _repository.updatePayment(orderId, PaymentStatus.failed, null);
    notifyListeners();
  }
}
