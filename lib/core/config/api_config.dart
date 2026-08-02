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
  static const String googleLogin = '$baseUrl/auth/google';

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
  static String orderReceipt(String id) => '$baseUrl/orders/$id/receipt';

  // ---------- Reviews ----------
  static String productReviews(String id) => '$baseUrl/products/$id/reviews';

  // ---------- Coupons ----------
  static const String coupons = '$baseUrl/coupons';
  static String validateCoupon(String code) => '$baseUrl/coupons/$code';

  // ---------- Settings ----------
  static const String storeSettings = '$baseUrl/settings';

  // ---------- Notifications ----------
  static const String registerDeviceToken = '$baseUrl/notifications/register';
  static const String notifications = '$baseUrl/notifications';

  // ---------- Reports ----------
  static const String salesReport = '$baseUrl/reports/sales';
  static const String inventoryReport = '$baseUrl/reports/inventory';
  static const String customersReport = '$baseUrl/reports/customers';

  // ================================================================
  //                    بوابة الدفع الإلكتروني (Paymob)
  // ================================================================
  // احصل على البيانات دي من لوحة تحكم Paymob بعد تفعيل حساب التاجر:
  // https://accept.paymob.com/portal2/en/PaymobDeveloperPortal
  //
  // سيبها فاضية والتطبيق هيشتغل بوضع تجريبي (Mock) عادي.
  static const String paymobApiKey = '';
  static const String paymobIntegrationId = '';
  static const String paymobIframeId = '';

  static const String paymentInit = '$baseUrl/payment/init';
  static const String paymentVerify = '$baseUrl/payment/verify';

  /// هل بيانات Paymob متوفرة؟ لو لأ بنستخدم الـ Mock.
  static bool get isPaymobConfigured =>
      paymobApiKey.isNotEmpty && paymobIntegrationId.isNotEmpty;

  // ================================================================
  //                      تسجيل الدخول بجوجل
  // ================================================================
  // من Google Cloud Console بعد إنشاء OAuth Client IDs:
  // https://console.cloud.google.com/apis/credentials
  //
  // سيبها فاضية والتطبيق هيستخدم وضع تجريبي.
  static const String googleWebClientId = '';
  static const String googleAndroidClientId = '';

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;
}
