import 'payout_account.dart';
import 'ticker_item.dart';

/// إعدادات المتجر — كل الميزات اللي صاحب المتجر يقدر يفتحها أو يقفلها.
class StoreSettings {
  const StoreSettings({
    this.tickerEnabled = true,
    this.tickerItems = const [],
    this.tickerSpeed = 3,
    this.recommendationsEnabled = true,
    this.recommendationsAuto = true,
    this.notificationsEnabled = true,
    this.notifyNewProducts = true,
    this.notifyInactivity = true,
    this.inactivityDays = 3,
    this.guestCheckoutEnabled = true,
    this.googleSignInEnabled = true,
    this.cardPaymentEnabled = true,
    this.codEnabled = true,
    this.reviewsEnabled = true,
    this.couponsEnabled = true,
    this.shippingFee = 60,
    this.freeShippingOver = 2000,
    this.storeName = 'Moda',
    this.storePhone = '01000000000',
    this.storeAddress = 'القاهرة، مصر',
    this.lowStockThreshold = 3,
    this.payout = const PayoutAccount(),
  });

  // ---------- الشريط المتحرك ----------
  final bool tickerEnabled;
  final List<TickerItem> tickerItems;

  /// عدد الثواني اللي كل عنصر يفضل ظاهر فيها.
  final int tickerSpeed;

  // ---------- المنتجات المقترحة ----------
  final bool recommendationsEnabled;

  /// true = يختار المنتجات المقترحة تلقائياً، false = المميزة فقط.
  final bool recommendationsAuto;

  // ---------- الإشعارات ----------
  final bool notificationsEnabled;
  final bool notifyNewProducts;
  final bool notifyInactivity;
  final int inactivityDays;

  // ---------- الطلب والدفع ----------
  final bool guestCheckoutEnabled;
  final bool googleSignInEnabled;
  final bool cardPaymentEnabled;
  final bool codEnabled;

  // ---------- ميزات إضافية ----------
  final bool reviewsEnabled;
  final bool couponsEnabled;

  // ---------- الشحن وبيانات المتجر ----------
  final double shippingFee;
  final double freeShippingOver;
  final String storeName;
  final String storePhone;
  final String storeAddress;
  final int lowStockThreshold;

  /// حساب استلام الأموال (بنك / محفظة / إنستاباي).
  final PayoutAccount payout;

  List<TickerItem> get activeTickerItems =>
      tickerItems.where((t) => t.enabled).toList();

  StoreSettings copyWith({
    bool? tickerEnabled,
    List<TickerItem>? tickerItems,
    int? tickerSpeed,
    bool? recommendationsEnabled,
    bool? recommendationsAuto,
    bool? notificationsEnabled,
    bool? notifyNewProducts,
    bool? notifyInactivity,
    int? inactivityDays,
    bool? guestCheckoutEnabled,
    bool? googleSignInEnabled,
    bool? cardPaymentEnabled,
    bool? codEnabled,
    bool? reviewsEnabled,
    bool? couponsEnabled,
    double? shippingFee,
    double? freeShippingOver,
    String? storeName,
    String? storePhone,
    String? storeAddress,
    int? lowStockThreshold,
    PayoutAccount? payout,
  }) {
    return StoreSettings(
      tickerEnabled: tickerEnabled ?? this.tickerEnabled,
      tickerItems: tickerItems ?? this.tickerItems,
      tickerSpeed: tickerSpeed ?? this.tickerSpeed,
      recommendationsEnabled:
          recommendationsEnabled ?? this.recommendationsEnabled,
      recommendationsAuto: recommendationsAuto ?? this.recommendationsAuto,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyNewProducts: notifyNewProducts ?? this.notifyNewProducts,
      notifyInactivity: notifyInactivity ?? this.notifyInactivity,
      inactivityDays: inactivityDays ?? this.inactivityDays,
      guestCheckoutEnabled: guestCheckoutEnabled ?? this.guestCheckoutEnabled,
      googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
      cardPaymentEnabled: cardPaymentEnabled ?? this.cardPaymentEnabled,
      codEnabled: codEnabled ?? this.codEnabled,
      reviewsEnabled: reviewsEnabled ?? this.reviewsEnabled,
      couponsEnabled: couponsEnabled ?? this.couponsEnabled,
      shippingFee: shippingFee ?? this.shippingFee,
      freeShippingOver: freeShippingOver ?? this.freeShippingOver,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      storeAddress: storeAddress ?? this.storeAddress,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      payout: payout ?? this.payout,
    );
  }

  factory StoreSettings.fromJson(Map<String, dynamic> json) => StoreSettings(
        tickerEnabled: json['tickerEnabled'] as bool? ?? true,
        tickerItems: (json['tickerItems'] as List? ?? [])
            .map((e) => TickerItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        tickerSpeed: (json['tickerSpeed'] as num?)?.toInt() ?? 3,
        recommendationsEnabled:
            json['recommendationsEnabled'] as bool? ?? true,
        recommendationsAuto: json['recommendationsAuto'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        notifyNewProducts: json['notifyNewProducts'] as bool? ?? true,
        notifyInactivity: json['notifyInactivity'] as bool? ?? true,
        inactivityDays: (json['inactivityDays'] as num?)?.toInt() ?? 3,
        guestCheckoutEnabled: json['guestCheckoutEnabled'] as bool? ?? true,
        googleSignInEnabled: json['googleSignInEnabled'] as bool? ?? true,
        cardPaymentEnabled: json['cardPaymentEnabled'] as bool? ?? true,
        codEnabled: json['codEnabled'] as bool? ?? true,
        reviewsEnabled: json['reviewsEnabled'] as bool? ?? true,
        couponsEnabled: json['couponsEnabled'] as bool? ?? true,
        shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 60,
        freeShippingOver:
            (json['freeShippingOver'] as num?)?.toDouble() ?? 2000,
        storeName: json['storeName'] as String? ?? 'Moda',
        storePhone: json['storePhone'] as String? ?? '01000000000',
        storeAddress: json['storeAddress'] as String? ?? 'القاهرة، مصر',
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 3,
        payout: json['payout'] == null
            ? const PayoutAccount()
            : PayoutAccount.fromJson(json['payout'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'tickerEnabled': tickerEnabled,
        'tickerItems': tickerItems.map((e) => e.toJson()).toList(),
        'tickerSpeed': tickerSpeed,
        'recommendationsEnabled': recommendationsEnabled,
        'recommendationsAuto': recommendationsAuto,
        'notificationsEnabled': notificationsEnabled,
        'notifyNewProducts': notifyNewProducts,
        'notifyInactivity': notifyInactivity,
        'inactivityDays': inactivityDays,
        'guestCheckoutEnabled': guestCheckoutEnabled,
        'googleSignInEnabled': googleSignInEnabled,
        'cardPaymentEnabled': cardPaymentEnabled,
        'codEnabled': codEnabled,
        'reviewsEnabled': reviewsEnabled,
        'couponsEnabled': couponsEnabled,
        'shippingFee': shippingFee,
        'freeShippingOver': freeShippingOver,
        'storeName': storeName,
        'storePhone': storePhone,
        'storeAddress': storeAddress,
        'lowStockThreshold': lowStockThreshold,
        'payout': payout.toJson(),
      };

  /// الإعدادات الافتراضية مع عناصر شريط جاهزة.
  static StoreSettings get initial => StoreSettings(
        tickerItems: [
          const TickerItem(
            id: 't1',
            type: TickerType.text,
            value: '🚚 شحن مجاني للطلبات فوق 2000 ج.م',
          ),
          const TickerItem(
            id: 't2',
            type: TickerType.text,
            value: '🔥 خصومات تصل إلى 40% على تشكيلة مختارة',
          ),
          const TickerItem(
            id: 't3',
            type: TickerType.text,
            value: '✨ وصل حديثاً — تشكيلة جديدة كل أسبوع',
          ),
        ],
      );
}
