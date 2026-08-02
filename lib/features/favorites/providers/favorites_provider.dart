import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';

/// المفضلة (قائمة الرغبات) — محفوظة محلياً.
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  Set<String> get ids => _ids;
  int get count => _ids.length;

  bool isFavorite(String productId) => _ids.contains(productId);

  Future<void> load() async {
    final raw = LocalStorage.getString(LocalStorage.keyFavorites);
    if (raw == null || raw.isEmpty) return;
    try {
      _ids
        ..clear()
        ..addAll(List<String>.from(jsonDecode(raw) as List));
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyFavorites);
    }
  }

  Future<void> toggle(String productId) async {
    if (!_ids.remove(productId)) _ids.add(productId);
    await LocalStorage.setString(
      LocalStorage.keyFavorites,
      jsonEncode(_ids.toList()),
    );
    notifyListeners();
  }
}
