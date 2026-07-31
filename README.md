# متجر أناقة 🖤🤍

تطبيق متجر إلكتروني كامل بـ **Flutter** لمتجر أزياء نسائية (أحذية – شنط – نظارات شمسية – إكسسوارات) بتصميم أبيض وأسود فاخر ودعم كامل للغة العربية (RTL).

يعمل التطبيق على **أندرويد** و **iOS** ويحتوي على واجهتين في نفس التطبيق:

| الدور | المميزات |
|---|---|
| 👩‍💼 **الأدمن (صاحبة المتجر)** | لوحة تحكم (إجمالي الطلبات – مبيعات اليوم – تنبيه المخزون المنخفض) • إدارة المنتجات (إضافة/تعديل/حذف مع صور من المعرض أو الكاميرا) • إدارة التصنيفات • إدارة الطلبات وتغيير حالتها • تقرير مبيعات |
| 🛍️ **العميلة** | تصفح الرئيسية (بانرات – تصنيفات – منتجات مميزة – وصل حديثاً) • تفاصيل المنتج (معرض صور – مقاسات – ألوان) • بحث وفلترة بالتصنيف والسعر • سلة تسوق محفوظة • إتمام الطلب (دفع عند الاستلام + شاشة مبدئية للدفع الإلكتروني عبر Paymob لاحقاً) • متابعة حالة الطلبات • تسجيل برقم الهاتف |

---

## 🔑 بيانات الدخول للتجربة

| الحساب | البيانات |
|---|---|
| **الأدمن** | البريد: `admin@store.com` — كلمة المرور: `123456` |
| **عميلة** | أنشئي حساباً جديداً برقم هاتف من شاشة التسجيل |

---

## 1️⃣ تثبيت Flutter SDK على ويندوز (خطوة بخطوة)

1. حمّلي Flutter SDK من الموقع الرسمي:
   👉 https://docs.flutter.dev/get-started/install/windows
2. فكّي ضغط الملف في مسار بسيط مثل: `C:\src\flutter`
   ⚠️ لا تضعيه داخل `C:\Program Files` لتجنب مشاكل الصلاحيات.
3. أضيفي Flutter إلى الـ PATH:
   - من قائمة ابدأ ابحثي عن **"Edit environment variables"**
   - افتحي **Environment Variables** ← اختاري **Path** ← **Edit** ← **New**
   - أضيفي: `C:\src\flutter\bin` ثم **OK**
4. ثبّتي **Android Studio** من: https://developer.android.com/studio
   (يحتوي على Android SDK والمحاكي)
5. افتحي **CMD** جديد ونفّذي:
   ```bash
   flutter doctor
   ```
   واتبعي أي تعليمات تظهر (مثل قبول التراخيص):
   ```bash
   flutter doctor --android-licenses
   ```

---

## 2️⃣ فتح المشروع

### في VS Code
1. ثبّتي إضافتي **Flutter** و **Dart** من الـ Extensions.
2. **File ← Open Folder** واختاري مجلد المشروع.

### في Android Studio
1. **File ← Open** واختاري مجلد المشروع.
2. ثبّتي إضافة Flutter لو طلب منك ذلك.

---

## 3️⃣ تشغيل التطبيق

1. شغّلي محاكي أندرويد من Android Studio (**Device Manager ← ▶**)
   أو وصّلي موبايل حقيقي بعد تفعيل **وضع المطور + USB Debugging**.
2. من داخل مجلد المشروع نفّذي:
   ```bash
   flutter pub get
   flutter run
   ```
3. أول تشغيل قد يستغرق عدة دقائق (تحميل Gradle والمكتبات) — هذا طبيعي.

> 💡 ملاحظة: صور المنتجات التجريبية تُحمّل من الإنترنت، فتأكدي من اتصال المحاكي/الهاتف بالإنترنت.

---

## 4️⃣ بناء نسخة APK للتوزيع

```bash
flutter build apk --release
```

ستجدين الملف الناتج في:
`build/app/outputs/flutter-apk/app-release.apk`

يمكن إرسال هذا الملف لأي هاتف أندرويد وتثبيته مباشرة.

> ⚠️ قبل النشر على Google Play يجب إنشاء مفتاح توقيع خاص بك — راجعي: https://docs.flutter.dev/deployment/android

---

## 5️⃣ نسخة iOS (آيفون)

- بناء نسخة iOS يتطلب جهاز **Mac** مع **Xcode** — لا يمكن بناؤها من ويندوز.
- على الـ Mac:
  ```bash
  flutter pub get
  cd ios && pod install && cd ..
  flutter run
  ```
- 💡 **بديل بدون Mac:** خدمة [Codemagic](https://codemagic.io) — خدمة سحابية تبني نسخة iOS من نفس المشروع وترفعها على App Store بدون امتلاك Mac.

---

## 🏗️ هيكل المشروع (Clean Architecture بالـ Features)

```
lib/
├── main.dart                     # نقطة البداية + الثيم + الـ Providers
├── core/
│   ├── config/api_config.dart    # ⭐ كل عناوين الـ API في ملف واحد (baseUrl)
│   ├── theme/app_theme.dart      # الثيم الأبيض/الأسود + خط Cairo
│   ├── storage/local_storage.dart# التخزين المحلي (shared_preferences)
│   ├── utils/formatters.dart     # تنسيق الأسعار والتواريخ
│   └── widgets/                  # عناصر واجهة مشتركة
└── features/
    ├── auth/       # تسجيل الدخول والتسجيل والحساب
    ├── products/   # المنتجات والتصنيفات والرئيسية والبحث
    ├── cart/       # سلة التسوق
    ├── orders/     # الطلبات وإتمام الشراء
    └── admin/      # لوحة تحكم الأدمن كاملة
```

كل feature يحتوي على:
- `data/` → الموديلات + الـ Repositories
- `providers/` → إدارة الحالة (Provider)
- `screens/` و `widgets/` → الواجهات

---

## 🔌 ربط التطبيق بالباك اند (ASP.NET Core) لاحقاً

التطبيق حالياً يعمل ببيانات تجريبية (Mock Repositories) بنفس واجهات الـ Repository النهائية:

1. افتحي `lib/core/config/api_config.dart` وغيّري:
   ```dart
   static const String baseUrl = 'https://your-api-domain.com/api';
   ```
2. أنشئي تنفيذاً جديداً لكل Repository يستدعي الـ API، مثال:
   ```dart
   class ApiProductRepository implements ProductRepository { ... }
   ```
3. استبدلي `MockProductRepository()` بـ `ApiProductRepository()` في الـ Provider — **بدون تغيير أي شاشة**.

الواجهات الجاهزة للاستبدال:
- `AuthRepository` (دخول/تسجيل)
- `ProductRepository` (المنتجات)
- `CategoryRepository` (التصنيفات)
- `OrderRepository` (الطلبات)

> ملاحظة: البيانات التجريبية (منتجات وطلبات) تعيش في الذاكرة وتعود لوضعها الأصلي عند إعادة تشغيل التطبيق. السلة وجلسة الدخول والحسابات المسجلة محفوظة محلياً.

---

## 🛠️ التقنيات المستخدمة

- Flutter (أحدث نسخة مستقرة) مع Null Safety
- **Provider** لإدارة الحالة
- **shared_preferences** لحفظ السلة وجلسة الدخول
- **google_fonts** (خط Cairo العربي)
- **image_picker** لصور المنتجات من المعرض/الكاميرا
- Material 3 + دعم RTL كامل

---

## ❓ حل المشاكل الشائعة

| المشكلة | الحل |
|---|---|
| `flutter` غير معروف في CMD | تأكدي من إضافة `C:\src\flutter\bin` للـ PATH وافتحي CMD جديد |
| فشل تحميل المكتبات | نفّذي `flutter clean` ثم `flutter pub get` |
| مشاكل في ملفات أندرويد/iOS مع نسخة Flutter مختلفة | نفّذي `flutter create .` داخل مجلد المشروع لإعادة توليد ملفات المنصات ثم `flutter run` |
| الصور لا تظهر | تأكدي من اتصال الجهاز بالإنترنت |
