/// طريقة استلام صاحب المتجر لفلوسه.
enum PayoutType { bank, wallet, instapay }

extension PayoutTypeX on PayoutType {
  String get labelAr => switch (this) {
        PayoutType.bank => 'حساب بنكي',
        PayoutType.wallet => 'محفظة إلكترونية',
        PayoutType.instapay => 'إنستاباي',
      };
}

/// بيانات الحساب اللي بيتحوّل عليه فلوس الطلبات المدفوعة بالبطاقة.
///
/// ⚠️ ملاحظة أمان مهمة:
/// البيانات دي بتتخزن على جهاز صاحب المتجر بس (تخزين محلي) عشان يشوفها
/// ويتأكد منها. **بوابة الدفع (Paymob) هي اللي بتحوّل الفلوس فعلياً** حسب
/// الحساب المسجّل عندهم في لوحة التاجر — مش من التطبيق.
/// فالحقول دي للتوثيق والمراجعة، والتحويل الحقيقي بيتظبط من موقع Paymob.
class PayoutAccount {
  const PayoutAccount({
    this.type = PayoutType.bank,
    this.holderName = '',
    this.bankName = '',
    this.accountNumber = '',
    this.iban = '',
    this.walletNumber = '',
    this.instapayAddress = '',
    this.merchantId = '',
    this.notes = '',
  });

  final PayoutType type;

  /// اسم صاحب الحساب كما هو في البنك.
  final String holderName;
  final String bankName;
  final String accountNumber;
  final String iban;

  /// رقم المحفظة (فودافون كاش / اتصالات كاش / أورنج كاش).
  final String walletNumber;

  /// عنوان إنستاباي (مثال: name@instapay).
  final String instapayAddress;

  /// رقم التاجر عند بوابة الدفع.
  final String merchantId;
  final String notes;

  /// هل البيانات الأساسية متعبّاية؟
  bool get isConfigured {
    if (holderName.trim().isEmpty) return false;
    return switch (type) {
      PayoutType.bank =>
        accountNumber.trim().isNotEmpty || iban.trim().isNotEmpty,
      PayoutType.wallet => walletNumber.trim().isNotEmpty,
      PayoutType.instapay => instapayAddress.trim().isNotEmpty,
    };
  }

  /// ملخص مختصر يظهر في شاشة الإعدادات.
  String get summary {
    if (!isConfigured) return 'لم يتم الإعداد بعد';
    return switch (type) {
      PayoutType.bank =>
        '$bankName · ${_mask(iban.isNotEmpty ? iban : accountNumber)}',
      PayoutType.wallet => 'محفظة · ${_mask(walletNumber)}',
      PayoutType.instapay => instapayAddress,
    };
  }

  /// يخفي كل الرقم ما عدا آخر ٤ خانات.
  static String _mask(String value) {
    final clean = value.trim();
    if (clean.length <= 4) return clean;
    return '•••• ${clean.substring(clean.length - 4)}';
  }

  PayoutAccount copyWith({
    PayoutType? type,
    String? holderName,
    String? bankName,
    String? accountNumber,
    String? iban,
    String? walletNumber,
    String? instapayAddress,
    String? merchantId,
    String? notes,
  }) =>
      PayoutAccount(
        type: type ?? this.type,
        holderName: holderName ?? this.holderName,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        iban: iban ?? this.iban,
        walletNumber: walletNumber ?? this.walletNumber,
        instapayAddress: instapayAddress ?? this.instapayAddress,
        merchantId: merchantId ?? this.merchantId,
        notes: notes ?? this.notes,
      );

  factory PayoutAccount.fromJson(Map<String, dynamic> json) => PayoutAccount(
        type: PayoutType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => PayoutType.bank,
        ),
        holderName: json['holderName'] as String? ?? '',
        bankName: json['bankName'] as String? ?? '',
        accountNumber: json['accountNumber'] as String? ?? '',
        iban: json['iban'] as String? ?? '',
        walletNumber: json['walletNumber'] as String? ?? '',
        instapayAddress: json['instapayAddress'] as String? ?? '',
        merchantId: json['merchantId'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'holderName': holderName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'iban': iban,
        'walletNumber': walletNumber,
        'instapayAddress': instapayAddress,
        'merchantId': merchantId,
        'notes': notes,
      };
}
