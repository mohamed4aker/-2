import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../data/models/order.dart';
import '../providers/orders_provider.dart';
import 'online_payment_screen.dart';
import 'order_success_screen.dart';

/// إتمام الطلب: بيانات التوصيل + طريقة الدفع.
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
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();

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
        total: cart.total,
      );
      cart.clear();
      if (!mounted) return;

      if (_paymentMethod == PaymentMethod.online) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnlinePaymentScreen(order: order),
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

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'بيانات التوصيل',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'الاسم',
              controller: _nameController,
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'أدخلي الاسم'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'رقم الهاتف',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'أدخلي رقم هاتف صحيح'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'العنوان بالتفصيل',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'أدخلي العنوان بالتفصيل'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'المدينة / المحافظة',
              controller: _cityController,
              icon: Icons.location_city_outlined,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'أدخلي المدينة'
                  : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              title: 'الدفع عند الاستلام',
              subtitle: 'ادفعي كاش لمندوب الشحن عند استلام الطلب',
              icon: Icons.payments_outlined,
              selected: _paymentMethod == PaymentMethod.cashOnDelivery,
              onTap: () => setState(
                  () => _paymentMethod = PaymentMethod.cashOnDelivery),
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              title: 'دفع إلكتروني',
              subtitle: 'بطاقة بنكية أو محفظة (سيتم تفعيله قريباً عبر Paymob)',
              icon: Icons.credit_card_outlined,
              selected: _paymentMethod == PaymentMethod.online,
              onTap: () =>
                  setState(() => _paymentMethod = PaymentMethod.online),
            ),
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
                  Row(
                    children: [
                      const Text('الشحن'),
                      const Spacer(),
                      Text(
                        cart.shipping == 0
                            ? 'مجاني'
                            : formatPrice(cart.shipping),
                        style:
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
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
                        formatPrice(cart.total),
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
              label: 'تأكيد الطلب',
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
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black,
            ),
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
