import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_storage.dart';
import 'mock_data.dart';
import 'models/product_category.dart';

/// واجهة مستودع التصنيفات.
abstract class CategoryRepository {
  Future<List<ProductCategory>> fetchCategories();
  Future<ProductCategory> addCategory(ProductCategory category);
  Future<ProductCategory> updateCategory(ProductCategory category);
  Future<void> deleteCategory(String id);

  /// بث حي للتصنيفات — نفس فكرة [ProductRepository.watchProducts].
  Stream<List<ProductCategory>>? watchCategories() => null;
}

/// تنفيذ محلي: التصنيفات محفوظة على الجهاز.
class MockCategoryRepository implements CategoryRepository {
  static List<ProductCategory>? _cache;

  static const _delay = Duration(milliseconds: 200);

  static List<ProductCategory> get store {
    if (_cache != null) return _cache!;

    final raw = LocalStorage.getString(LocalStorage.keyCategories);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = (jsonDecode(raw) as List)
            .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cache!;
      } catch (_) {
        // بيانات تالفة — نبدأ من جديد.
      }
    }

    // التصنيفات الأربعة الأساسية بتتحمّل دايماً (حتى بدون بيانات تجريبية)
    // عشان صاحب المتجر يلاقي مكان يضيف فيه منتجاته على طول.
    _cache = List.of(MockData.categories);
    _persist();
    return _cache!;
  }

  static void _persist() {
    if (_cache == null) return;
    LocalStorage.setString(
      LocalStorage.keyCategories,
      jsonEncode(_cache!.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Stream<List<ProductCategory>>? watchCategories() => null;

  @override
  Future<List<ProductCategory>> fetchCategories() async {
    await Future.delayed(_delay);
    return List.of(store);
  }

  @override
  Future<ProductCategory> addCategory(ProductCategory category) async {
    await Future.delayed(_delay);
    store.add(category);
    _persist();
    return category;
  }

  @override
  Future<ProductCategory> updateCategory(ProductCategory category) async {
    await Future.delayed(_delay);
    final index = store.indexWhere((c) => c.id == category.id);
    if (index == -1) {
      throw Exception('التصنيف غير موجود');
    }
    store[index] = category;
    _persist();
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(_delay);
    store.removeWhere((c) => c.id == id);
    _persist();
  }

  /// إعادة التصنيفات للوضع الافتراضي.
  static Future<void> resetToDefault() async {
    _cache = List.of(MockData.categories);
    _persist();
  }

  /// مستخدم فقط للتأكد من قراءة الإعداد عند التصفير.
  static bool get demoEnabled => AppConfig.useDemoData;
}
