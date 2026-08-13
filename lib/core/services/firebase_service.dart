import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// تهيئة Firebase بشكل آمن.
///
/// لو الإعداد ناقص (ملف google-services.json مش موجود مثلاً)، التطبيق
/// **مش هيقع** — هيشتغل بالوضع المحلي عادي ويسجّل السبب في الكونسول.
class FirebaseService {
  FirebaseService._();

  static bool _ready = false;
  static String? _error;

  /// هل Firebase شغال فعلاً دلوقتي؟
  static bool get isReady => _ready;

  /// سبب فشل الاتصال (لو فيه).
  static String? get error => _error;

  static Future<void> init() async {
    if (AppConfig.backend != BackendType.firebase) return;

    try {
      // على أندرويد و iOS بيقرأ الإعدادات تلقائياً من:
      //   android/app/google-services.json
      //   ios/Runner/GoogleService-Info.plist
      await Firebase.initializeApp();
      _ready = true;
      debugPrint('✅ Firebase متصل — التطبيق شغال بالسيرفر');
    } catch (e) {
      _ready = false;
      _error = e.toString();
      debugPrint(
        '⚠️ فشل الاتصال بـ Firebase — التطبيق هيشتغل بالوضع المحلي.\n'
        'السبب: $e\n'
        'راجع خطوات إعداد Firebase في ملف README.',
      );
    }
  }
}
