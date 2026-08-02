import 'package:flutter/foundation.dart';

import '../data/category_repository.dart';
import '../data/models/product.dart';
import '../data/models/product_category.dart';
import '../data/product_repository.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _productRepository = productRepository ?? MockProductRepository(),
        _categoryRepository = categoryRepository ?? MockCategoryRepository();

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  List<Product> get featured =>
      _products.where((p) => p.isFeatured).toList();

  List<Product> get newArrivals {
    final list = List.of(_products);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(6).toList();
  }

  List<Product> lowStockBelow(int threshold) =>
      _products.where((p) => p.stock <= threshold).toList();

  List<Product> get lowStock => lowStockBelow(3);

  /// المنتجات اللي عليها خصم — لقسم "عروض وخصومات".
  List<Product> get discounted =>
      _products.where((p) => p.hasDiscount).toList();

  double get maxPrice => _products.isEmpty
      ? 5000
      : _products
          .map((p) => p.finalPrice)
          .reduce((a, b) => a > b ? a : b);

  Product? productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Product> byCategory(String categoryId) =>
      _products.where((p) => p.categoryId == categoryId).toList();

  String categoryName(String categoryId) {
    for (final c in _categories) {
      if (c.id == categoryId) return c.name;
    }
    return '';
  }

  /// بحث + فلترة بالتصنيف والسعر.
  List<Product> search({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) {
    final q = query.trim();
    return _products.where((p) {
      if (q.isNotEmpty &&
          !p.name.contains(q) &&
          !p.description.contains(q)) {
        return false;
      }
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (minPrice != null && p.finalPrice < minPrice) return false;
      if (maxPrice != null && p.finalPrice > maxPrice) return false;
      return true;
    }).toList();
  }

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _productRepository.fetchProducts(),
        _categoryRepository.fetchCategories(),
      ]);
      _products = results[0] as List<Product>;
      _categories = results[1] as List<ProductCategory>;
      _loaded = true;
    } catch (e) {
      _error = 'تعذر تحميل المنتجات، حاول مرة أخرى';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------- عمليات الأدمن ----------

  Future<void> addProduct(Product product) async {
    await _productRepository.addProduct(product);
    await load(force: true);
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
    await load(force: true);
  }

  Future<void> deleteProduct(String id) async {
    await _productRepository.deleteProduct(id);
    await load(force: true);
  }

  Future<void> addCategory(String name) async {
    final category = ProductCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
    );
    await _categoryRepository.addCategory(category);
    await load(force: true);
  }

  Future<void> updateCategory(ProductCategory category) async {
    await _categoryRepository.updateCategory(category);
    await load(force: true);
  }

  /// حذف تصنيف — يرفض الحذف لو فيه منتجات مرتبطة به.
  Future<bool> deleteCategory(String id) async {
    if (_products.any((p) => p.categoryId == id)) return false;
    await _categoryRepository.deleteCategory(id);
    await load(force: true);
    return true;
  }
}
