import 'mock_data.dart';
import 'models/product.dart';

/// واجهة مستودع المنتجات.
///
/// لاستبدال الـ Mock بالـ API الحقيقي: أنشئ class جديد
/// `ApiProductRepository implements ProductRepository`
/// يستدعي endpoints موجودة في [ApiConfig]، ثم استخدمه في ProductsProvider.
abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

/// تنفيذ تجريبي يعمل بالكامل في الذاكرة.
class MockProductRepository implements ProductRepository {
  /// مخزن مشترك بين كل نسخ الـ repository أثناء تشغيل التطبيق.
  static final List<Product> store = List.of(MockData.products);

  static const _delay = Duration(milliseconds: 350);

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(_delay);
    return List.of(store);
  }

  @override
  Future<Product> addProduct(Product product) async {
    await Future.delayed(_delay);
    store.add(product);
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
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(_delay);
    store.removeWhere((p) => p.id == id);
  }

  /// خصم الكمية من المخزون بعد إنشاء طلب (يستخدمه mock الطلبات).
  static void decreaseStock(String productId, int quantity) {
    final index = store.indexWhere((p) => p.id == productId);
    if (index == -1) return;
    final product = store[index];
    final newStock = product.stock - quantity;
    store[index] = product.copyWith(stock: newStock < 0 ? 0 : newStock);
  }
}
