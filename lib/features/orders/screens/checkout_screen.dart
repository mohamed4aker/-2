import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/models/order.dart';
import '../providers/orders_provider.dart';
import 'card_payment_screen.dart';
import 'order_success_screen.dart';

/// إتمام الطلب: بيانات التوصيل + كود الخصم + طريقة الدفع.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  bool _submitting = false;
  String? _couponError;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController =
        TextEditingController(text: user?.isGuest == true ? '' : user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');

    final settings = context.read<SettingsProvider>().settings;
    if (!settings.codEnabled && settings.cardPaymentEnabled) {
      _paymentMethod = PaymentMethod.card;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final error =
        context.read<CartProvider>().applyCoupon(_couponController.text);
    setState(() => _couponError = error);
    if (error == null) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تطبيق كود الخصم ✅')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    final settings = context.read<SettingsProvider>().settings;

    setState(() => _submitting = true);
    try {
      final order = await orders.placeOrder(
        userId: auth.user?.id ?? 'guest',
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        paymentMethod: _paymentMethod,
        cartItems: cart.items,
        subtotal: cart.subtotal,
        shipping: cart.shipping(settings),
        discount: cart.couponDiscount,
        couponCode: cart.coupon?.code,
        total: cart.total(settings),
        isGuestOrder: auth.isGuest,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      cart.clear();
      if (!mounted) return;

      if (_paymentMethod == PaymentMethod.card) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CardPaymentScreen(order: order),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: order),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (auth.isGuest)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'بتطلب كضيف — الطلب هيتسجّل عادي، بس مش هتقدر تتابعه '
                        'من "طلباتي" إلا لو عملت حساب',
                        style: TextStyle(fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              'بيانات التوصيل',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'الاسم',
              controller: _nameController,
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'أدخل الاسم' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'رقم الهاتف',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'أدخل رقم هاتف صحيح'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'العنوان بالتفصيل',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'أدخل العنوان بالتفصيل'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'المدينة / المحافظة',
              controller: _cityController,
              icon: Icons.location_city_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل المدينة' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'ملاحظات للطلب (اختياري)',
              controller: _notesController,
              icon: Icons.notes_outlined,
              maxLines: 2,
            ),

            // ---------- كود الخصم ----------
            if (settings.couponsEnabled) ...[
              const SizedBox(height: 24),
              const Text(
                'كود الخصم',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (cart.coupon != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${cart.coupon!.code} — ${cart.coupon!.label}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          cart.removeCoupon();
                          _couponController.clear();
                        },
                      ),
                    ],
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _couponController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'مثال: ANAQA10',
                          errorText: _couponError,
                          prefixIcon:
                              const Icon(Icons.local_offer_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 56),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('تطبيق'),
                    ),
                  ],
                ),
            ],

            // ---------- طريقة الدفع ----------
            const SizedBox(height: 24),
            const Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (settings.codEnabled)
              _PaymentOption(
                title: 'الدفع عند الاستلام',
                subtitle: 'ادفع كاش لمندوب الشحن عند استلام الطلب',
                icon: Icons.payments_outlined,
                selected: _paymentMethod == PaymentMethod.cashOnDelivery,
                onTap: () => setState(
                    () => _paymentMethod = PaymentMethod.cashOnDelivery),
              ),
            if (settings.codEnabled && settings.cardPaymentEnabled)
              const SizedBox(height: 8),
            if (settings.cardPaymentEnabled)
              _PaymentOption(
                title: 'بطاقة بنكية',
                subtitle: 'فيزا / ماستركارد / ميزة — دفع آمن ومشفّر',
                icon: Icons.credit_card_outlined,
                selected: _paymentMethod == PaymentMethod.card,
                onTap: () =>
                    setState(() => _paymentMethod = PaymentMethod.card),
              ),

            // ---------- الملخص ----------
            const SizedBox(height: 24),
            const Text(
              'ملخص الطلب',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} × ${item.quantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            formatPrice(item.total),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  _SummaryLine(
                    label: 'المجموع',
                    value: formatPrice(cart.subtotal),
                  ),
                  if (cart.productsSaving > 0)
                    _SummaryLine(
                      label: 'وفّرت من خصومات المنتجات',
                      value: '- ${formatPrice(cart.productsSaving)}',
                    ),
                  if (cart.couponDiscount > 0)
                    _SummaryLine(
                      label: 'خصم الكوبون',
                      value: '- ${formatPrice(cart.couponDiscount)}',
                    ),
                  _SummaryLine(
                    label: 'الشحن',
                    value: cart.shipping(settings) == 0
                        ? 'مجاني'
                        : formatPrice(cart.shipping(settings)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatPrice(cart.total(settings)),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: _paymentMethod == PaymentMethod.card
                  ? 'المتابعة للدفع'
                  : 'تأكيد الطلب',
              loading: _submitting,
              onPressed: cart.isEmpty ? null : _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          border: Border.all(
            color: selected ? Colors.black : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? Colors.white : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
