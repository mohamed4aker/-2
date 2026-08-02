import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../data/models/store_settings.dart';
import '../data/models/ticker_item.dart';

/// يدير إعدادات المتجر ويحفظها محلياً.
class SettingsProvider extends ChangeNotifier {
  StoreSettings _settings = StoreSettings.initial;

  StoreSettings get settings => _settings;

  Future<void> load() async {
    final raw = LocalStorage.getString(LocalStorage.keyStoreSettings);
    if (raw == null || raw.isEmpty) return;
    try {
      _settings =
          StoreSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyStoreSettings);
    }
  }

  Future<void> update(StoreSettings settings) async {
    _settings = settings;
    await LocalStorage.setString(
      LocalStorage.keyStoreSettings,
      jsonEncode(settings.toJson()),
    );
    notifyListeners();
  }

  // ---------- عناصر الشريط المتحرك ----------

  Future<void> addTickerItem(TickerType type, String value) async {
    final items = List<TickerItem>.of(_settings.tickerItems)
      ..add(TickerItem(
        id: 'tk_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        value: value,
      ));
    await update(_settings.copyWith(tickerItems: items));
  }

  Future<void> updateTickerItem(String id, {String? value, bool? enabled}) {
    final items = _settings.tickerItems
        .map((t) => t.id == id ? t.copyWith(value: value, enabled: enabled) : t)
        .toList();
    return update(_settings.copyWith(tickerItems: items));
  }

  Future<void> removeTickerItem(String id) {
    final items =
        _settings.tickerItems.where((t) => t.id != id).toList();
    return update(_settings.copyWith(tickerItems: items));
  }

  Future<void> reorderTicker(int oldIndex, int newIndex) {
    final items = List<TickerItem>.of(_settings.tickerItems);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    return update(_settings.copyWith(tickerItems: items));
  }
}
