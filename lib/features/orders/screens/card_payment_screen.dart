import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/models/order.dart';
import '../data/payment_gateway.dart';
import '../providers/orders_provider.dart';
import 'order_success_screen.dart';

/// شاشة الدفع بالبطاقة (فيزا / ماستركارد / ميزة).
///
/// حالياً بتستخدم [MockPaymentGateway] للتجربة — لتفعيل Paymob الحقيقي
/// راجع التعليمات في ملف payment_gateway.dart.
class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key, required this.order});

  final Order order;

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final PaymentGateway _gateway = MockPaymentGateway();
  bool _processing = false;
  String? _failure;

  @override
  void initState() {
    super.initState();
    _numberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _processing = true;
      _failure = null;
    });

    try {
      final result = await _gateway.charge(
        amount: widget.order.total,
        cardNumber: _numberController.text,
        holderName: _nameController.text,
        expiry: _expiryController.text,
        cvv: _cvvController.text,
        orderId: widget.order.id,
      );

      if (!mounted) return;

      if (!result.success) {
        setState(() => _failure = result.message ?? 'فشلت عملية الدفع');
        await context.read<OrdersProvider>().markPaymentFailed(
              widget.order.id,
            );
        return;
      }

      final paid = await context.read<OrdersProvider>().markPaid(
            widget.order.id,
            result.transactionId,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: paid),
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = CardValidator.brandOf(_numberController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('الدفع بالبطاقة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- شكل البطاقة ----------
            Container(
              height: 190,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white38),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        brand.isEmpty ? 'CARD' : brand.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _numberController.text.isEmpty
                          ? '#### #### #### ####'
                          : _numberController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _nameController.text.isEmpty
                              ? 'اسم صاحب البطاقة'
                              : _nameController.text.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        _expiryController.text.isEmpty
                            ? 'MM/YY'
                            : _expiryController.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'رقم البطاقة',
              controller: _numberController,
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              validator: (v) => CardValidator.isValidNumber(v ?? '')
                  ? null
                  : 'رقم البطاقة غير صحيح',
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'اسم صاحب البطاقة',
              controller: _nameController,
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'أدخل اسم صاحب البطاقة'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'تاريخ الانتهاء (MM/YY)',
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    validator: (v) => CardValidator.isValidExpiry(v ?? '')
                        ? null
                        : 'تاريخ غير صحيح',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'CVV',
                    controller: _cvvController,
                    obscure: true,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    validator: (v) => CardValidator.isValidCvv(v ?? '')
                        ? null
                        : 'غير صحيح',
                  ),
                ),
              ],
            ),

            if (_failure != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _failure!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('طلب ${widget.order.id}'),
                  const Spacer(),
                  Text(
                    formatPrice(widget.order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'ادفع ${formatPrice(widget.order.total)}',
              icon: Icons.lock_outline,
              loading: _processing,
              onPressed: _pay,
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: AppTheme.grey),
                SizedBox(width: 6),
                Text(
                  'بياناتك محمية ومشفّرة',
                  style: TextStyle(fontSize: 12, color: AppTheme.grey),
                ),
              ],
            ),

            if (!ApiConfig.isPaymobConfigured) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧪 وضع التجربة',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'بوابة الدفع لسه مربوطة بحساب تجريبي. استخدم رقم بطاقة '
                      'صحيح الشكل مثل 4242 4242 4242 4242 عشان تجرّب نجاح '
                      'العملية، أو رقم منتهي بـ 0000 عشان تجرّب فشل الدفع.\n\n'
                      'لتفعيل الدفع الحقيقي: حط بيانات Paymob في ملف '
                      'api_config.dart',
                      style: TextStyle(fontSize: 12, height: 1.7),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// يخلي إدخال رقم البطاقة يتقسّم كل 4 أرقام تلقائياً.
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 19; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
