import '../../../core/config/api_config.dart';

/// نتيجة عملية الدفع.
class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.transactionId,
    this.message,
  });

  final bool success;
  final String transactionId;
  final String? message;
}

/// واجهة بوابة الدفع الإلكتروني.
///
/// ------------------------------------------------------------------
/// للربط بـ Paymob الحقيقي لاحقاً:
/// 1. اعمل حساب تاجر على https://paymob.com واحصل على:
///    - API Key
///    - Integration ID (بطاقات)
///    - iframe ID
/// 2. حطهم في [ApiConfig] (المتغيرات جاهزة هناك).
/// 3. اعمل class جديد `PaymobGateway implements PaymentGateway` يعمل:
///    أ. طلب توكن المصادقة  (auth token)
///    ب. تسجيل الطلب        (order registration)
///    ج. طلب مفتاح الدفع    (payment key)
///    د. يفتح صفحة الـ iframe في WebView ويستنى نتيجة العملية
/// 4. بدّل `MockPaymentGateway()` بـ `PaymobGateway()` في CheckoutScreen.
///
/// الشاشات وتدفق الدفع كله جاهز — مش محتاج تغيّر أي واجهة.
/// ------------------------------------------------------------------
abstract class PaymentGateway {
  Future<PaymentResult> charge({
    required double amount,
    required String cardNumber,
    required String holderName,
    required String expiry,
    required String cvv,
    required String orderId,
  });
}

/// تنفيذ تجريبي للتطوير والاختبار.
///
/// يقبل أي بطاقة صحيحة الشكل، ويرفض البطاقات اللي بتنتهي بـ `0000`
/// عشان تقدر تجرّب حالة فشل الدفع.
class MockPaymentGateway implements PaymentGateway {
  @override
  Future<PaymentResult> charge({
    required double amount,
    required String cardNumber,
    required String holderName,
    required String expiry,
    required String cvv,
    required String orderId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (digits.endsWith('0000')) {
      return const PaymentResult(
        success: false,
        transactionId: '',
        message: 'تم رفض البطاقة من البنك، جرّب بطاقة أخرى',
      );
    }

    return PaymentResult(
      success: true,
      transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      message: 'تمت العملية بنجاح',
    );
  }
}

/// أدوات التحقق من بيانات البطاقة.
class CardValidator {
  CardValidator._();

  /// خوارزمية Luhn — نفس اللي البنوك بتستخدمها للتحقق من رقم البطاقة.
  static bool isValidNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// يتأكد إن تاريخ الانتهاء بصيغة MM/YY وإنه لسه ساري.
  static bool isValidExpiry(String input) {
    final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(input.trim());
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return false;
    // آخر لحظة في شهر الانتهاء.
    final expiry = DateTime(year, month + 1, 0, 23, 59);
    return expiry.isAfter(DateTime.now());
  }

  static bool isValidCvv(String input) =>
      RegExp(r'^\d{3,4}$').hasMatch(input.trim());

  /// يحدد نوع البطاقة من أول رقم.
  static String brandOf(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(digits)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    if (digits.startsWith('6')) return 'Meeza';
    return '';
  }
}
