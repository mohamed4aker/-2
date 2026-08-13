import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import 'models/product.dart';
import 'product_repository.dart';

/// مستودع المنتجات على سيرفر Firebase.
///
/// أي منتج بيتضاف من لوحة التحكم بيتحفظ على السيرفر فوراً،
/// وكل العملاء بيشوفوه على موبايلاتهم من غير تحديث التطبيق.
class FirebaseProductRepository implements ProductRepository {
  final _collection =
      FirebaseFirestore.instance.collection(AppConfig.collectionProducts);

  @override
  Future<List<Product>> fetchProducts() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  /// بث حي للمنتجات — أي تعديل على السيرفر بيوصل للشاشة فوراً.
  Stream<List<Product>> watchProducts() =>
      _collection.snapshots().map((s) => s.docs.map(_fromDoc).toList());

  @override
  Future<Product> addProduct(Product product) async {
    await _collection.doc(product.id).set(product.toJson());
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _collection.doc(product.id).update(product.toJson());
    return product;
  }

  @override
  Future<void> deleteProduct(String id) => _collection.doc(id).delete();

  /// خصم الكمية من المخزون بشكل آمن حتى لو اتنين طلبوا في نفس اللحظة.
  Future<void> decreaseStock(String productId, int quantity) async {
    final ref = _collection.doc(productId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) return;
      final current = (snapshot.data()?['stock'] as num?)?.toInt() ?? 0;
      final updated = current - quantity;
      tx.update(ref, {'stock': updated < 0 ? 0 : updated});
    });
  }

  Product _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    return Product.fromJson(data);
  }
}
