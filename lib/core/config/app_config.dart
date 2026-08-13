/// مصدر البيانات اللي التطبيق بيشتغل بيه.
enum BackendType {
  /// تخزين على الجهاز نفسه — للتجربة والعرض فقط.
  /// المنتجات اللي تضيفها مش هتظهر لأي حد تاني.
  local,

  /// سيرفر Firebase — كل العملاء يشوفوا نفس المنتجات والطلبات توصلك.
  firebase,
}

/// إعدادات عامة للتطبيق تتحكم في سلوكه قبل النشر.
class AppConfig {
  AppConfig._();

  /// ======================================================================
  ///                🔴 أهم مفتاحين في المشروع كله
  /// ======================================================================

  /// **١. مصدر البيانات**
  ///
  /// - [BackendType.local]    → التطبيق شغال على الجهاز بس (للعرض والتجربة)
  /// - [BackendType.firebase] → التطبيق متصل بالسيرفر (متجر حقيقي)
  ///
  /// سيبها `local` لحد ما تخلص إعداد Firebase (الخطوات في README)،
  /// وبعدين غيّرها لـ `firebase`.
  ///
  /// ملاحظة: لو غيّرتها لـ firebase من غير ما تحط ملف google-services.json
  /// التطبيق هيرجع تلقائياً للوضع المحلي بدل ما يقع.
  static const BackendType backend = BackendType.local;

  /// **٢. البيانات التجريبية**
  ///
  /// true  = يبدأ بـ ١٤ منتج و٥ طلبات تجريبية (للعرض)
  /// false = يبدأ فاضي تماماً (للإطلاق الحقيقي)
  ///
  /// بتأثر على الوضع المحلي بس — مع Firebase البيانات بتيجي من السيرفر.
  static const bool useDemoData = true;

  /// هل التطبيق متصل بسيرفر؟
  static bool get isOnline => backend == BackendType.firebase;

  static const String appVersion = '1.0.0';
  static const String appName = 'Moda';

  // ---------------- أسماء الجداول في Firestore ----------------
  static const String collectionProducts = 'products';
  static const String collectionCategories = 'categories';
  static const String collectionOrders = 'orders';
  static const String collectionUsers = 'users';
  static const String collectionSettings = 'settings';
  static const String collectionReviews = 'reviews';

  /// البريد اللي بيتعامل كأدمن (صاحب المتجر).
  /// غيّره لبريدك الحقيقي قبل الإطلاق.
  static const String adminEmail = 'admin@store.com';
}
