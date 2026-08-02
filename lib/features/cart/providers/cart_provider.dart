import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../../orders/data/models/coupon.dart';
import '../../products/data/models/product.dart';
import '../../settings/data/models/store_settings.dart';
import '../data/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Coupon? _coupon;

  List<CartItem> get items => _items.values.toList();

  Coupon? get coupon => _coupon;

  int get itemsCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  /// إجمالي المنتجات بعد خصومات المنتجات نفسها.
  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.total);

  /// إجمالي السعر قبل أي خصم على المنتجات.
  double get subtotalBeforeDiscount => _items.values
      .fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  /// قيمة ما وفّره العميل من خصومات المنتجات.
  double get productsSaving => subtotalBeforeDiscount - subtotal;

  /// قيمة خصم الكوبون.
  double get couponDiscount => _coupon?.discountFor(subtotal) ?? 0;

  double shipping(StoreSettings settings) {
    if (isEmpty) return 0;
    final afterDiscount = subtotal - couponDiscount;
    return afterDiscount >= settings.freeShippingOver
        ? 0
        : settings.shippingFee;
  }

  double total(StoreSettings settings) =>
      subtotal - couponDiscount + shipping(settings);

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

  /// يحاول تطبيق كود خصم. يرجّع رسالة الخطأ أو null لو نجح.
  String? applyCoupon(String code) {
    final found = CouponStore.find(code);
    if (found == null) return 'كود الخصم غير صحيح أو منتهي';
    if (subtotal < found.minOrder) {
      return 'الكود ده للطلبات فوق ${found.minOrder.toStringAsFixed(0)} ج.م';
    }
    _coupon = found;
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _coupon = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _coupon = null;
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
