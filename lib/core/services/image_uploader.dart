import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'firebase_service.dart';

/// رفع صور المنتجات على السيرفر.
///
/// من غير الرفع ده، الصور بتفضل على موبايل صاحب المتجر بس والعملاء
/// هيشوفوا مربعات فاضية. الكلاس ده بيرفع الصورة ويرجّع رابط إنترنت
/// كل الناس تقدر تفتحه.
class ImageUploader {
  ImageUploader._();

  /// يرفع صورة واحدة ويرجّع رابطها.
  /// لو التطبيق في الوضع المحلي بيرجّع المسار زي ما هو.
  static Future<String> upload(String localPath) async {
    // الوضع المحلي أو Firebase مش جاهز → سيب المسار زي ما هو.
    if (!AppConfig.isOnline || !FirebaseService.isReady) return localPath;

    // الرابط ده اترفع قبل كده.
    if (localPath.startsWith('http')) return localPath;

    try {
      final name =
          'products/${DateTime.now().millisecondsSinceEpoch}_${localPath.hashCode}.jpg';
      final ref = FirebaseStorage.instance.ref().child(name);
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('⚠️ فشل رفع الصورة: $e');
      // بنرجّع المسار المحلي عشان الحفظ ميفشلش بالكامل.
      return localPath;
    }
  }

  /// يرفع مجموعة صور بالترتيب ويرجّع روابطها.
  static Future<List<String>> uploadAll(List<String> paths) async {
    final urls = <String>[];
    for (final path in paths) {
      urls.add(await upload(path));
    }
    return urls;
  }

  /// يمسح صورة من السيرفر (عند حذف منتج).
  static Future<void> delete(String url) async {
    if (!AppConfig.isOnline || !FirebaseService.isReady) return;
    if (!url.startsWith('http')) return;
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      debugPrint('تعذر حذف الصورة: $e');
    }
  }
}
