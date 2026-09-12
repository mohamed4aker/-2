import '../../orders/data/models/order.dart';
import 'models/product.dart';

/// محرك اقتراح المنتجات المكمّلة ("ممكن يعجبك مع ده").
///
/// بيشتغل بطريقتين:
/// 1. **تلقائي**: بيتعلم من الطلبات السابقة — لو ناس اشترت الشنطة دي
///    مع جزمة معينة، هيقترح الجزمة دي لأي حد يفتح الشنطة.
/// 2. **احتياطي**: لو لسه مفيش طلبات كفاية، بيقترح منتجات مميزة من
///    تصنيفات مكمّلة (شنطة ← جزمة + نظارة + إكسسوار).
class RecommendationEngine {
  RecommendationEngine._();

  /// التصنيفات اللي بتتماشى مع بعض في الإطلالة الواحدة.
  static const Map<String, List<String>> _complementary = {
    'cat_bags': ['cat_shoes', 'cat_sunglasses', 'cat_accessories'],
    'cat_shoes': ['cat_bags', 'cat_accessories', 'cat_sunglasses'],
    'cat_sunglasses': ['cat_bags', 'cat_accessories', 'cat_shoes'],
    'cat_accessories': ['cat_bags', 'cat_shoes', 'cat_sunglasses'],
  };

  /// يرجّع منتجات مقترحة مع [product].
  ///
  /// [auto] لو true بيستخدم تحليل الطلبات السابقة، ولو false بيرجّع
  /// المنتجات المميزة من التصنيفات المكمّلة بس.
  static List<Product> suggestFor(
    Product product, {
    required List<Product> allProducts,
    required List<Order> orders,
    bool auto = true,
    int limit = 6,
  }) {
    final result = <Product>[];
    final usedIds = <String>{product.id};

    // نفس المنتج بلون تاني مش "اقتراح" — ده بيظهر في شريط الألوان
    // تحت الصورة، فبنستبعده من "كمّل إطلالتك".
    if (product.hasVariants) {
      final group = product.variantGroup!.trim();
      for (final p in allProducts) {
        if (p.variantGroup?.trim() == group) usedIds.add(p.id);
      }
    }

    if (auto) {
      // ١. المنتجات اللي اتشترت مع المنتج ده في نفس الطلب (الأكثر تكراراً أولاً).
      final coCount = <String, int>{};
      for (final order in orders) {
        final ids = order.items.map((i) => i.productId).toSet();
        if (!ids.contains(product.id)) continue;
        for (final id in ids) {
          if (id == product.id) continue;
          coCount[id] = (coCount[id] ?? 0) + 1;
        }
      }
      final sorted = coCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted) {
        final match = _findById(allProducts, entry.key);
        if (match != null && match.inStock && usedIds.add(match.id)) {
          result.add(match);
          if (result.length >= limit) return result;
        }
      }
    }

    // ٢. تكملة من التصنيفات المكمّلة (المميزة والمخفّضة أولاً).
    final categories = _complementary[product.categoryId] ??
        _otherCategories(allProducts, product.categoryId);

    for (final categoryId in categories) {
      final candidates = allProducts
          .where((p) =>
              p.categoryId == categoryId &&
              p.inStock &&
              !usedIds.contains(p.id))
          .toList()
        ..sort((a, b) {
          final aScore = (a.isFeatured ? 2 : 0) + (a.hasDiscount ? 1 : 0);
          final bScore = (b.isFeatured ? 2 : 0) + (b.hasDiscount ? 1 : 0);
          return bScore.compareTo(aScore);
        });

      for (final candidate in candidates) {
        if (usedIds.add(candidate.id)) {
          result.add(candidate);
          if (result.length >= limit) return result;
        }
        // منتج واحد بس من كل تصنيف في اللفة الأولى عشان التنوع.
        break;
      }
    }

    // ٣. لو لسه ناقص، كمّل من أي تصنيف مكمّل.
    for (final categoryId in categories) {
      for (final candidate in allProducts.where((p) =>
          p.categoryId == categoryId &&
          p.inStock &&
          !usedIds.contains(p.id))) {
        usedIds.add(candidate.id);
        result.add(candidate);
        if (result.length >= limit) return result;
      }
    }

    return result;
  }

  static Product? _findById(List<Product> products, String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<String> _otherCategories(
    List<Product> products,
    String exceptId,
  ) {
    final ids = <String>{};
    for (final p in products) {
      if (p.categoryId != exceptId) ids.add(p.categoryId);
    }
    return ids.toList();
  }
}
