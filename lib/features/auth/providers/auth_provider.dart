import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? MockAuthRepository();

  final AuthRepository _repository;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get loading => _loading;
  String? get error => _error;

  /// محاولة استرجاع الجلسة المحفوظة عند فتح التطبيق.
  Future<void> tryAutoLogin() async {
    final raw = LocalStorage.getString(LocalStorage.keyAuthUser);
    if (raw == null || raw.isEmpty) return;
    try {
      _user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyAuthUser);
    }
  }

  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.login(identifier, password);
      await _persistSession();
      _error = null;
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String phone, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.register(name, phone, password);
      await _persistSession();
      _error = null;
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
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

  String _cleanError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
