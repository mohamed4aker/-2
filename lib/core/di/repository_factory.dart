import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/orders/data/firebase_order_repository.dart';
import '../../features/orders/data/order_repository.dart';
import '../../features/products/data/category_repository.dart';
import '../../features/products/data/firebase_category_repository.dart';
import '../../features/products/data/firebase_product_repository.dart';
import '../../features/products/data/product_repository.dart';
import '../config/app_config.dart';
import '../services/firebase_service.dart';

/// المكان الوحيد اللي بيقرر التطبيق يشتغل بالسيرفر ولا محلياً.
///
/// لو `AppConfig.backend = firebase` **و** الاتصال نجح → مستودعات Firebase.
/// غير كده → المستودعات المحلية (عشان التطبيق يفضل شغال في كل الأحوال).
class RepositoryFactory {
  RepositoryFactory._();

  static bool get _useFirebase =>
      AppConfig.backend == BackendType.firebase && FirebaseService.isReady;

  static ProductRepository products() => _useFirebase
      ? FirebaseProductRepository()
      : MockProductRepository();

  static CategoryRepository categories() => _useFirebase
      ? FirebaseCategoryRepository()
      : MockCategoryRepository();

  static OrderRepository orders() =>
      _useFirebase ? FirebaseOrderRepository() : MockOrderRepository();

  static AuthRepository auth() =>
      _useFirebase ? FirebaseAuthRepository() : MockAuthRepository();

  /// وصف حالة الاتصال — بيظهر لصاحب المتجر في لوحة التحكم.
  static String get statusLabel {
    if (AppConfig.backend == BackendType.local) {
      return 'وضع محلي — البيانات على الجهاز ده بس';
    }
    if (!FirebaseService.isReady) {
      return 'فشل الاتصال بالسيرفر — التطبيق شغال محلياً';
    }
    return 'متصل بالسيرفر ✅';
  }

  static bool get isOnline => _useFirebase;
}
