import 'dart:convert';

import '../../../core/storage/local_storage.dart';
import 'models/app_user.dart';

/// واجهة مستودع المصادقة.
abstract class AuthRepository {
  /// تسجيل الدخول بالبريد الإلكتروني أو رقم الهاتف + كلمة المرور.
  Future<AppUser> login(String identifier, String password);

  /// تسجيل عميل جديد برقم الهاتف.
  Future<AppUser> register(String name, String phone, String password);
}

/// تنفيذ تجريبي: حساب الأدمن ثابت، وحسابات العملاء تُحفظ في التخزين المحلي.
class MockAuthRepository implements AuthRepository {
  static const _delay = Duration(milliseconds: 500);

  /// حساب صاحب المتجر (للاختبار).
  static const AppUser _admin = AppUser(
    id: 'admin_1',
    name: 'صاحبة المتجر',
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
}
