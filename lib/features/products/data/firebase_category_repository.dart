import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import 'category_repository.dart';
import 'mock_data.dart';
import 'models/product_category.dart';

/// مستودع التصنيفات على سيرفر Firebase.
class FirebaseCategoryRepository implements CategoryRepository {
  final _collection =
      FirebaseFirestore.instance.collection(AppConfig.collectionCategories);

  @override
  Future<List<ProductCategory>> fetchCategories() async {
    final snapshot = await _collection.get();

    // أول مرة يشتغل التطبيق: نزرع التصنيفات الأربعة الأساسية
    // عشان صاحب المتجر يلاقي مكان يضيف فيه منتجاته على طول.
    if (snapshot.docs.isEmpty) {
      await _seedDefaults();
      final seeded = await _collection.get();
      return seeded.docs.map(_fromDoc).toList();
    }

    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<ProductCategory>> watchCategories() =>
      _collection.snapshots().map((s) => s.docs.map(_fromDoc).toList());

  Future<void> _seedDefaults() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final category in MockData.categories) {
      batch.set(_collection.doc(category.id), category.toJson());
    }
    await batch.commit();
  }

  @override
  Future<ProductCategory> addCategory(ProductCategory category) async {
    await _collection.doc(category.id).set(category.toJson());
    return category;
  }

  @override
  Future<ProductCategory> updateCategory(ProductCategory category) async {
    await _collection.doc(category.id).update(category.toJson());
    return category;
  }

  @override
  Future<void> deleteCategory(String id) => _collection.doc(id).delete();

  ProductCategory _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    return ProductCategory.fromJson(data);
  }
}
