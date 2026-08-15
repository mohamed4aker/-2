// Firestore بيصدّر كلاس اسمه Order كمان، فبنخفيه عشان ميتعارضش
// مع كلاس الطلب بتاعنا.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../../core/config/app_config.dart';
import '../../products/data/firebase_product_repository.dart';
import 'models/order.dart';
import 'order_repository.dart';

/// مستودع الطلبات على سيرفر Firebase.
///
/// الطلب اللي العميل يعمله من موبايله بيوصل لوحة تحكم صاحب المتجر فوراً.
class FirebaseOrderRepository implements OrderRepository {
  final _collection =
      FirebaseFirestore.instance.collection(AppConfig.collectionOrders);

  final _products = FirebaseProductRepository();

  @override
  Future<List<Order>> fetchAllOrders() async {
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  /// بث حي لكل الطلبات — لوحة تحكم الأدمن بتتحدث لحظياً.
  Stream<List<Order>> watchAllOrders() => _collection
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Future<List<Order>> fetchUserOrders(String userId) async {
    // بنرتّب في التطبيق بدل السيرفر عشان منحتاجش فهرس مركّب في Firestore.
    final snapshot =
        await _collection.where('userId', isEqualTo: userId).get();
    final list = snapshot.docs.map(_fromDoc).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Stream<List<Order>> watchUserOrders(String userId) => _collection
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final list = s.docs.map(_fromDoc).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  @override
  Future<Order> createOrder(Order order) async {
    await _collection.doc(order.id).set(order.toJson());
    // خصم الكميات من المخزون على السيرفر.
    for (final item in order.items) {
      await _products.decreaseStock(item.productId, item.quantity);
    }
    return order;
  }

  @override
  Future<Order> updateStatus(String orderId, OrderStatus status) async {
    await _collection.doc(orderId).update({'status': status.name});
    final doc = await _collection.doc(orderId).get();
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<Order> updatePayment(
    String orderId,
    PaymentStatus status,
    String? transactionId,
  ) async {
    await _collection.doc(orderId).update({
      'paymentStatus': status.name,
      if (transactionId != null) 'transactionId': transactionId,
    });
    final doc = await _collection.doc(orderId).get();
    return _fromMap(doc.id, doc.data()!);
  }

  Order _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _fromMap(doc.id, doc.data());

  Order _fromMap(String id, Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);
    data['id'] = id;
    // Firestore ممكن يرجّع التاريخ كـ Timestamp بدل نص.
    final created = data['createdAt'];
    if (created is Timestamp) {
      data['createdAt'] = created.toDate().toIso8601String();
    }
    return Order.fromJson(data);
  }
}
