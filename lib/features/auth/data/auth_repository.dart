import 'dart:convert';

import '../../../core/config/api_config.dart';
import '../../../core/storage/local_storage.dart';
import 'models/app_user.dart';

/// واجهة مستودع المصادقة.
abstract class AuthRepository {
  /// تسجيل الدخول بالبريد الإلكتروني أو رقم الهاتف + كلمة المرور.
  Future<AppUser> login(String identifier, String password);

  /// تسجيل عميل جديد برقم الهاتف.
  Future<AppUser> register(String name, String phone, String password);

  /// تسجيل الدخول بحساب جوجل.
  Future<AppUser> loginWithGoogle();

  /// الدخول كضيف (للطلب من غير تسجيل).
  Future<AppUser> continueAsGuest();

  /// إنهاء الجلسة (مهم مع السيرفر عشان الحساب ما يفضلش مفتوح).
  Future<void> logout();
}

/// تنفيذ تجريبي: حساب الأدمن ثابت، وحسابات العملاء تُحفظ في التخزين المحلي.
class MockAuthRepository implements AuthRepository {
  static const _delay = Duration(milliseconds: 500);

  /// حساب صاحب المتجر (للاختبار).
  static const AppUser _admin = AppUser(
    id: 'admin_1',
    name: 'صاحب المتجر',
    phone: '01000000000',
    email: 'admin@store.com',
    password: '123456',
    role: UserRole.admin,
  );

  List<AppUser> _loadRegisteredUsers() {
    final raw = LocalStorage.getString(LocalStorage.keyRegisteredUsers);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveRegisteredUsers(List<AppUser> users) async {
    await LocalStorage.setString(
      LocalStorage.keyRegisteredUsers,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  @override
  Future<AppUser> login(String identifier, String password) async {
    await Future.delayed(_delay);
    final id = identifier.trim();

    if ((id == _admin.email || id == _admin.phone) &&
        password == _admin.password) {
      return _admin;
    }

    final users = _loadRegisteredUsers();
    for (final user in users) {
      if ((user.phone == id || user.email == id) &&
          user.password == password) {
        return user;
      }
    }
    throw Exception('بيانات الدخول غير صحيحة، تأكد من رقم الهاتف وكلمة المرور');
  }

  @override
  Future<AppUser> register(String name, String phone, String password) async {
    await Future.delayed(_delay);
    final users = _loadRegisteredUsers();

    if (phone.trim() == _admin.phone ||
        users.any((u) => u.phone == phone.trim())) {
      throw Exception('رقم الهاتف مسجل بالفعل، جرّب تسجيل الدخول');
    }

    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      password: password,
      role: UserRole.customer,
    );
    users.add(user);
    await _saveRegisteredUsers(users);
    return user;
  }

  /// ------------------------------------------------------------------
  /// تسجيل الدخول بجوجل
  ///
  /// النسخة دي تجريبية بتنشئ حساب جوجل وهمي عشان التطبيق يشتغل من غير
  /// أي إعدادات خارجية.
  ///
  /// **للتفعيل الحقيقي:**
  /// 1. ضيف الحزمة في pubspec.yaml:  google_sign_in: ^6.2.1
  /// 2. اعمل مشروع على https://console.firebase.google.com
  /// 3. حمّل ملف google-services.json وحطه في android/app/
  /// 4. سجّل بصمة SHA-1 بتاعتك في Firebase:
  ///    cd android && ./gradlew signingReport
  /// 5. حط الـ Client ID في ApiConfig.googleWebClientId
  /// 6. بدّل الكود اللي تحت بـ:
  ///
  ///    final account = await GoogleSignIn(
  ///      clientId: ApiConfig.googleWebClientId,
  ///    ).signIn();
  ///    if (account == null) throw Exception('تم إلغاء تسجيل الدخول');
  ///    return AppUser(
  ///      id: 'g_${account.id}',
  ///      name: account.displayName ?? 'مستخدم جوجل',
  ///      phone: '',
  ///      email: account.email,
  ///      password: '',
  ///      role: UserRole.customer,
  ///      provider: AuthMethod.google,
  ///      photoUrl: account.photoUrl,
  ///    );
  /// ------------------------------------------------------------------
  @override
  Future<AppUser> loginWithGoogle() async {
    await Future.delayed(_delay);

    if (ApiConfig.isGoogleConfigured) {
      throw Exception(
        'بيانات جوجل موجودة لكن الحزمة لسه مفعّلة — راجع تعليمات '
        'التفعيل في ملف auth_repository.dart',
      );
    }

    final users = _loadRegisteredUsers();
    // نستخدم نفس حساب جوجل التجريبي لو اتسجل قبل كده.
    for (final user in users) {
      if (user.provider == AuthMethod.google) return user;
    }

    final user = AppUser(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      name: 'حساب جوجل تجريبي',
      phone: '',
      email: 'google.user@gmail.com',
      password: '',
      role: UserRole.customer,
      provider: AuthMethod.google,
    );
    users.add(user);
    await _saveRegisteredUsers(users);
    return user;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser> continueAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'ضيف',
      phone: '',
      password: '',
      role: UserRole.customer,
      provider: AuthMethod.guest,
    );
  }
}
