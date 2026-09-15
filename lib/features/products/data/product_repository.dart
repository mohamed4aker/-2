import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_storage.dart';
import 'mock_data.dart';
import 'models/product.dart';

/// واجهة مستودع المنتجات.
///
/// لاستبدال التخزين المحلي بالـ API الحقيقي: أنشئ class جديد
/// `ApiProductRepository implements ProductRepository`
/// يستدعي endpoints موجودة في [ApiConfig]، ثم استخدمه في ProductsProvider.
abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);

  /// بث حي للمنتجات — أي منتج يضيفه صاحب المتجر يوصل لموبايلات العملاء
  /// المفتوحة في نفس اللحظة من غير ما يقفلوا التطبيق ويفتحوه.
  ///
  /// بيرجّع null في التخزين المحلي (مفيش سيرفر يبعت تحديثات).
  Stream<List<Product>>? watchProducts() => null;
}

/// تنفيذ محلي: المنتجات محفوظة على الجهاز وبتفضل موجودة بعد قفل التطبيق.
///
/// ⚠️ التخزين ده **على الجهاز الواحد بس**. المنتجات اللي بتضيفها من موبايلك
/// مش هتظهر لعملاء تانيين على موبايلاتهم — عشان كده لازم باك اند حقيقي
/// قبل الإطلاق الفعلي (اقرأ قسم "الربط بالباك اند" في README).
class MockProductRepository implements ProductRepository {
  static List<Product>? _cache;

  static const _delay = Duration(milliseconds: 250);

  /// قراءة المنتجات من التخزين المحلي (أو البيانات التجريبية أول مرة).
  static List<Product> get store {
    if (_cache != null) return _cache!;

    final raw = LocalStorage.getString(LocalStorage.keyProducts);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = (jsonDecode(raw) as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cache!;
      } catch (_) {
        // بيانات تالفة — نبدأ من جديد.
      }
    }

    _cache = AppConfig.useDemoData ? List.of(MockData.products) : <Product>[];
    _persist();
    return _cache!;
  }

  static void _persist() {
    if (_cache == null) return;
    LocalStorage.setString(
      LocalStorage.keyProducts,
      jsonEncode(_cache!.map((p) => p.toJson()).toList()),
    );
  }

  /// التخزين المحلي مفيهوش بث حي — مفيش سيرفر يبعت تحديثات.
  @override
  Stream<List<Product>>? watchProducts() => null;

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(_delay);
    return List.of(store);
  }

  @override
  Future<Product> addProduct(Product product) async {
    await Future.delayed(_delay);
    store.add(product);
    _persist();
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(_delay);
    final index = store.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      throw Exception('المنتج غير موجود');
    }
    store[index] = product;
    _persist();
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(_delay);
    store.removeWhere((p) => p.id == id);
    _persist();
  }

  /// خصم الكمية من المخزون بعد إنشاء طلب.
  static void decreaseStock(String productId, int quantity) {
    final index = store.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    final product = store[index];
    final newStock = product.stock - quantity;
    store[index] = product.copyWith(stock: newStock < 0 ? 0 : newStock);
    _persist();
  }

  /// مسح كل المنتجات (يُستخدم من زر "تصفير البيانات" في لوحة التحكم).
  static Future<void> clearAll() async {
    _cache = <Product>[];
    await LocalStorage.setString(LocalStorage.keyProducts, '[]');
  }
}
