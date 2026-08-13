import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/local_storage.dart';
import '../data/models/review.dart';

/// تقييمات المنتجات (محفوظة محلياً — استبدلها بـ API لاحقاً).
class ReviewsProvider extends ChangeNotifier {
  List<Review> _reviews = _seed();

  static List<Review> _seed() {
    if (!AppConfig.useDemoData) return [];
    final now = DateTime.now();
    return [
      Review(
        id: 'r1',
        productId: 'p1',
        userName: 'سارة م.',
        rating: 5,
        comment: 'الجودة ممتازة والمقاس مظبوط، هطلب تاني إن شاء الله',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Review(
        id: 'r2',
        productId: 'p1',
        userName: 'نهى ع.',
        rating: 4,
        comment: 'حلوة جداً بس الكعب عالي شوية عن المتوقع',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      Review(
        id: 'r3',
        productId: 'p5',
        userName: 'منى أ.',
        rating: 5,
        comment: 'الشنطة أجمل من الصور، الجلد فخم والحجم عملي',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Review> forProduct(String productId) {
    final list =
        _reviews.where((r) => r.productId == productId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  double averageFor(String productId) {
    final list = forProduct(productId);
    if (list.isEmpty) return 0;
    final sum = list.fold<int>(0, (s, r) => s + r.rating);
    return sum / list.length;
  }

  int countFor(String productId) => forProduct(productId).length;

  Future<void> load() async {
    final raw = LocalStorage.getString(LocalStorage.keyReviews);
    if (raw == null || raw.isEmpty) return;
    try {
      _reviews = (jsonDecode(raw) as List)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      await LocalStorage.remove(LocalStorage.keyReviews);
    }
  }

  /// مسح كل التقييمات (من زر تصفير البيانات).
  Future<void> clearAll() async {
    _reviews = [];
    await LocalStorage.setString(LocalStorage.keyReviews, '[]');
    notifyListeners();
  }

  Future<void> add({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    _reviews.add(Review(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userName: userName,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    ));
    await LocalStorage.setString(
      LocalStorage.keyReviews,
      jsonEncode(_reviews.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }
}
