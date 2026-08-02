import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../../products/data/models/product.dart';
import '../../settings/data/models/store_settings.dart';
import '../data/models/app_notification.dart';

/// مركز الإشعارات داخل التطبيق.
///
/// بيولّد إشعارات تلقائية في الحالات دي:
/// - نزول منتجات جديدة (منتج لسه العميل مشافوش)
/// - العميل بقاله فترة مفتحش التطبيق
/// - تغيّر حالة طلب
///
/// ملاحظة: دي إشعارات داخل التطبيق (تظهر في تبويب الإشعارات مع عدّاد).
/// لتفعيل إشعارات نظام التشغيل (اللي بتظهر والتطبيق مقفول) راجع
/// قسم "الإشعارات" في ملف README.
class NotificationsProvider extends ChangeNotifier {
  List<AppNotification> _items = [];

  List<AppNotification> get items {
    final list = List<AppNotification>.of(_items);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    final raw = LocalStorage.getString(LocalStorage.keyNotifications);
    if (raw == null || raw.isEmpty) return;
    try {
      _items = (jsonDecode(raw) as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyNotifications);
    }
  }

  Future<void> _persist() => LocalStorage.setString(
        LocalStorage.keyNotifications,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );

  Future<void> push({
    required String title,
    required String body,
    required NotificationType type,
    String? productId,
    String? orderId,
  }) async {
    _items.add(AppNotification(
      id: 'n_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      productId: productId,
      orderId: orderId,
    ));
    // نحتفظ بآخر 50 إشعار فقط.
    if (_items.length > 50) {
      _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _items = _items.take(50).toList();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    _items = _items.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    _items = _items.map((n) => n.copyWith(read: true)).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = [];
    await _persist();
    notifyListeners();
  }

  /// يفحص المنتجات الجديدة وغياب العميل وينشئ الإشعارات المناسبة.
  /// بينادى مرة عند فتح التطبيق.
  Future<void> runAutoChecks({
    required List<Product> products,
    required StoreSettings settings,
  }) async {
    if (!settings.notificationsEnabled) return;

    // ---------- منتجات جديدة ----------
    if (settings.notifyNewProducts) {
      final seenRaw = LocalStorage.getString(LocalStorage.keySeenProductIds);
      final seen = <String>{};
      if (seenRaw != null && seenRaw.isNotEmpty) {
        seen.addAll(List<String>.from(jsonDecode(seenRaw) as List));
      }

      final isFirstRun = seen.isEmpty;
      final newOnes =
          products.where((p) => !seen.contains(p.id)).toList();

      // أول تشغيل بنسجّل المنتجات من غير إشعارات مزعجة.
      if (!isFirstRun && newOnes.isNotEmpty) {
        if (newOnes.length == 1) {
          await push(
            title: 'وصل حديثاً 🛍️',
            body: 'نزل منتج جديد: ${newOnes.first.name}',
            type: NotificationType.newProduct,
            productId: newOnes.first.id,
          );
        } else {
          await push(
            title: 'وصل حديثاً 🛍️',
            body: 'نزلت ${newOnes.length} منتجات جديدة — شوفها دلوقتي',
            type: NotificationType.newProduct,
          );
        }
      }

      await LocalStorage.setString(
        LocalStorage.keySeenProductIds,
        jsonEncode(products.map((p) => p.id).toList()),
      );
    }

    // ---------- غياب العميل ----------
    if (settings.notifyInactivity) {
      final lastRaw = LocalStorage.getString(LocalStorage.keyLastOpened);
      if (lastRaw != null && lastRaw.isNotEmpty) {
        final last = DateTime.tryParse(lastRaw);
        if (last != null) {
          final days = DateTime.now().difference(last).inDays;
          if (days >= settings.inactivityDays) {
            await push(
              title: 'وحشتنا! 💔',
              body:
                  'بقالك $days يوم مدخلتش المتجر — في تشكيلة جديدة مستنياك',
              type: NotificationType.reminder,
            );
          }
        }
      }
      await LocalStorage.setString(
        LocalStorage.keyLastOpened,
        DateTime.now().toIso8601String(),
      );
    }
  }
}
