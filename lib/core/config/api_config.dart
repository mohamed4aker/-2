/// إعدادات الـ API في مكان واحد.
///
/// عند ربط التطبيق بالباك اند (ASP.NET Core REST API) غيّر [baseUrl] فقط،
/// ثم أنشئ Repositories جديدة (مثل ApiProductRepository) تستدعي هذه الـ endpoints
/// بدلاً من الـ Mock Repositories الحالية.
class ApiConfig {
  ApiConfig._();

  /// عنوان السيرفر الأساسي - غيّره إلى عنوان الـ API الخاص بك.
  static const String baseUrl = 'https://your-api-domain.com/api';

  // ---------- Auth ----------
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // ---------- Products ----------
  static const String products = '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/$id';

  // ---------- Categories ----------
  static const String categories = '$baseUrl/categories';
  static String categoryById(String id) => '$baseUrl/categories/$id';

  // ---------- Orders ----------
  static const String orders = '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';
  static String ordersByUser(String userId) => '$baseUrl/orders/user/$userId';
  static String orderStatus(String id) => '$baseUrl/orders/$id/status';

  // ---------- Reports ----------
  static const String salesReport = '$baseUrl/reports/sales';

  // ---------- Payment (Paymob لاحقاً) ----------
  static const String paymentInit = '$baseUrl/payment/init';
}
