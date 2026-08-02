import 'package:shared_preferences/shared_preferences.dart';

/// طبقة تخزين محلي بسيطة فوق shared_preferences.
class LocalStorage {
  LocalStorage._();

  static late SharedPreferences _prefs;

  // مفاتيح التخزين
  static const String keyAuthUser = 'auth_user';
  static const String keyAuthToken = 'auth_token';
  static const String keyCartItems = 'cart_items';
  static const String keyRegisteredUsers = 'registered_users';
  static const String keyStoreSettings = 'store_settings';
  static const String keyFavorites = 'favorites';
  static const String keyNotifications = 'notifications';
  static const String keyLastOpened = 'last_opened_at';
  static const String keySeenProductIds = 'seen_product_ids';
  static const String keyReviews = 'product_reviews';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);
}
