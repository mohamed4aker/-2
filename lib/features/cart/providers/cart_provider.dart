import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../../products/data/models/product.dart';
import '../data/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemsCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.total);

  /// الشحن: مجاني فوق 2000 ج.م وإلا 60 ج.م.
  double get shipping => isEmpty || subtotal >= 2000 ? 0 : 60;

  double get total => subtotal + shipping;

  /// تحميل السلة المحفوظة من التخزين المحلي.
  Future<void> loadCart() async {
    final raw = LocalStorage.getString(LocalStorage.keyCartItems);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      _items.clear();
      for (final entry in list) {
        final item = CartItem.fromJson(entry as Map<String, dynamic>);
        _items[item.key] = item;
      }
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyCartItems);
    }
  }

  void addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) {
    final item = CartItem(
      product: product,
      quantity: quantity,
      size: size,
      color: color,
    );
    final existing = _items[item.key];
    if (existing != null) {
      _items[item.key] =
          existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items[item.key] = item;
    }
    _persist();
    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    final item = _items[key];
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(key);
    } else {
      _items[key] = item.copyWith(quantity: quantity);
    }
    _persist();
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    LocalStorage.setString(
      LocalStorage.keyCartItems,
      jsonEncode(_items.values.map((e) => e.toJson()).toList()),
    );
  }
}
