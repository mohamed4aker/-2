import 'mock_data.dart';
import 'models/product_category.dart';

/// واجهة مستودع التصنيفات.
abstract class CategoryRepository {
  Future<List<ProductCategory>> fetchCategories();
  Future<ProductCategory> addCategory(ProductCategory category);
  Future<ProductCategory> updateCategory(ProductCategory category);
  Future<void> deleteCategory(String id);
}

/// تنفيذ تجريبي في الذاكرة.
class MockCategoryRepository implements CategoryRepository {
  static final List<ProductCategory> store = List.of(MockData.categories);

  static const _delay = Duration(milliseconds: 250);

  @override
  Future<List<ProductCategory>> fetchCategories() async {
    await Future.delayed(_delay);
    return List.of(store);
  }

  @override
  Future<ProductCategory> addCategory(ProductCategory category) async {
    await Future.delayed(_delay);
    store.add(category);
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
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(_delay);
    store.removeWhere((c) => c.id == id);
  }
}
