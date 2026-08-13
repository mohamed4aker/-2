import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/di/repository_factory.dart';
import '../../../core/storage/local_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? RepositoryFactory.auth();

  final AuthRepository _repository;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isGuest => _user?.isGuest ?? false;
  bool get loading => _loading;
  String? get error => _error;

  /// محاولة استرجاع الجلسة المحفوظة عند فتح التطبيق.
  Future<void> tryAutoLogin() async {
    final raw = LocalStorage.getString(LocalStorage.keyAuthUser);
    if (raw == null || raw.isEmpty) return;
    try {
      final user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // جلسات الضيوف ما بتتحفظش بين مرات التشغيل.
      if (user.isGuest) {
        await LocalStorage.remove(LocalStorage.keyAuthUser);
        return;
      }
      _user = user;
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyAuthUser);
    }
  }

  Future<bool> login(String identifier, String password) =>
      _run(() => _repository.login(identifier, password));

  Future<bool> register(String name, String phone, String password) =>
      _run(() => _repository.register(name, phone, password));

  Future<bool> loginWithGoogle() => _run(_repository.loginWithGoogle);

  Future<bool> continueAsGuest() =>
      _run(_repository.continueAsGuest, persist: false);

  Future<bool> _run(
    Future<AppUser> Function() action, {
    bool persist = true,
  }) async {
    _setLoading(true);
    try {
      _user = await action();
      if (persist) await _persistSession();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// يحوّل حساب الضيف لحساب دائم بعد ما يقرر يسجّل.
  Future<void> upgradeGuest(AppUser user) async {
    _user = user;
    await _persistSession();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // لو فشل إنهاء الجلسة على السيرفر بنكمّل الخروج محلياً برضه.
    }
    _user = null;
    await LocalStorage.remove(LocalStorage.keyAuthUser);
    await LocalStorage.remove(LocalStorage.keyAuthToken);
    notifyListeners();
  }

  Future<void> _persistSession() async {
    if (_user == null) return;
    await LocalStorage.setString(
      LocalStorage.keyAuthUser,
      jsonEncode(_user!.toJson()),
    );
    // توكن تجريبي — مع الـ API الحقيقي خزّن الـ JWT القادم من السيرفر.
    await LocalStorage.setString(
      LocalStorage.keyAuthToken,
      'mock-token-${_user!.id}',
    );
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
