import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/di/repository_factory.dart';
import '../data/category_repository.dart';
import '../data/models/product.dart';
import '../data/models/product_category.dart';
import '../data/product_repository.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _productRepository = productRepository ?? RepositoryFactory.products(),
        _categoryRepository =
            categoryRepository ?? RepositoryFactory.categories();

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

  // ==================== التصنيفات المتداخلة ====================

  /// التصنيفات الرئيسية فقط (اللي مالهاش أب) — دي اللي بتظهر في الرئيسية.
  List<ProductCategory> get rootCategories =>
      _categories.where((c) => c.isRoot).toList();

  /// التصنيفات الفرعية التابعة لتصنيف معين.
  List<ProductCategory> childrenOf(String categoryId) =>
      _categories.where((c) => c.parentId == categoryId).toList();

  bool hasChildren(String categoryId) =>
      _categories.any((c) => c.parentId == categoryId);

  ProductCategory? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// كل التصنيفات اللي ممكن يتحط فيها منتج (اللي مالهاش فروع).
  /// عشان المنتج ميتحطش في "رجالي" وهي جواها "أحذية" و"شنط".
  List<ProductCategory> get leafCategories =>
      _categories.where((c) => !hasChildren(c.id)).toList();

  /// المسار الكامل للتصنيف — مثال: "رجالي ← أحذية"
  String categoryPath(String categoryId) {
    final parts = <String>[];
    var current = categoryById(categoryId);
    var guard = 0;
    while (current != null && guard++ < 10) {
      parts.insert(0, current.name);
      current = current.parentId == null
          ? null
          : categoryById(current.parentId!);
    }
    return parts.join(' ← ');
  }

  /// كل التصنيفات الفرعية (على أي عمق) تحت تصنيف معين، شاملة التصنيف نفسه.
  List<String> _descendantIds(String categoryId) {
    final ids = <String>[categoryId];
    for (final child in childrenOf(categoryId)) {
      ids.addAll(_descendantIds(child.id));
    }
    return ids;
  }

  /// منتجات التصنيف — بتشمل منتجات التصنيفات الفرعية كمان.
  List<Product> byCategory(String categoryId) {
    final ids = _descendantIds(categoryId).toSet();
    return _products.where((p) => ids.contains(p.categoryId)).toList();
  }

  /// عدد المنتجات داخل التصنيف وفروعه.
  int productsCountIn(String categoryId) => byCategory(categoryId).length;

  // ==================== مجموعات الألوان ====================

  /// باقي ألوان نفس المنتج (من غير المنتج الحالي).
  List<Product> variantsOf(Product product) {
    if (!product.hasVariants) return const [];
    final group = product.variantGroup!.trim();
    return _products
        .where((p) =>
            p.id != product.id &&
            p.variantGroup != null &&
            p.variantGroup!.trim() == group)
        .toList();
  }

  /// كل ألوان المجموعة بالترتيب (شاملة المنتج نفسه) — لعرض شريط الألوان.
  List<Product> variantGroupOf(Product product) {
    if (!product.hasVariants) return [product];
    final group = product.variantGroup!.trim();
    final list = _products
        .where((p) => p.variantGroup?.trim() == group)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  /// كل أسماء مجموعات الألوان الموجودة — بتظهر للأدمن كاقتراحات.
  List<String> get variantGroups {
    final groups = <String>{};
    for (final p in _products) {
      if (p.hasVariants) groups.add(p.variantGroup!.trim());
    }
    final list = groups.toList()..sort();
    return list;
  }

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
    // لو التصنيف المختار جواه أقسام، بنجيب منتجات الأقسام دي كمان.
    final allowedCategories =
        categoryId == null ? null : _descendantIds(categoryId).toSet();
    return _products.where((p) {
      if (q.isNotEmpty &&
          !p.name.contains(q) &&
          !p.description.contains(q)) {
        return false;
      }
      if (allowedCategories != null &&
          !allowedCategories.contains(p.categoryId)) {
        return false;
      }
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
      _startWatching();
    } catch (e) {
      _error = 'تعذر تحميل المنتجات، حاول مرة أخرى';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ==================== التحديث الحي ====================

  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<ProductCategory>>? _categoriesSub;

  /// بيفضل سامع للسيرفر، فأي منتج يضيفه صاحب المتجر يظهر عند العملاء
  /// في نفس اللحظة من غير ما يقفلوا التطبيق أو يسحبوا الشاشة لتحت.
  ///
  /// في الوضع المحلي المستودعات بترجّع null فالدالة دي مش بتعمل حاجة.
  void _startWatching() {
    if (_productsSub != null || _categoriesSub != null) return;

    final productStream = _productRepository.watchProducts();
    if (productStream != null) {
      _productsSub = productStream.listen(
        (items) {
          _products = items;
          _error = null;
          notifyListeners();
        },
        onError: (_) {
          // انقطاع مؤقت في النت — بنسيب آخر بيانات ظاهرة زي ما هي.
        },
      );
    }

    final categoryStream = _categoryRepository.watchCategories();
    if (categoryStream != null) {
      _categoriesSub = categoryStream.listen(
        (items) {
          _categories = items;
          notifyListeners();
        },
        onError: (_) {},
      );
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    super.dispose();
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

  Future<void> addCategory(String name, {String? parentId}) async {
    final category = ProductCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      parentId: parentId,
    );
    await _categoryRepository.addCategory(category);
    await load(force: true);
  }

  Future<void> updateCategory(ProductCategory category) async {
    await _categoryRepository.updateCategory(category);
    await load(force: true);
  }

  /// حذف تصنيف — يرفض الحذف لو فيه منتجات أو تصنيفات فرعية.
  Future<bool> deleteCategory(String id) async {
    if (_products.any((p) => p.categoryId == id)) return false;
    if (hasChildren(id)) return false;
    await _categoryRepository.deleteCategory(id);
    await load(force: true);
    return true;
  }
}
