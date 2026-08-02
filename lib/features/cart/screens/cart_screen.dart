import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/product_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../orders/screens/checkout_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _goToCheckout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final proceeded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(popOnSuccess: true),
        ),
      );
      if (proceeded != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(title: const Text('سلة التسوق')),
      body: cart.isEmpty
          ? const EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'السلة فاضية',
              subtitle: 'اتصفح المنتجات وضيف اللي يعجبك',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImage(
                                path: item.product.mainImage,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if (item.size != null)
                                        'مقاس ${item.size}',
                                      if (item.color != null) item.color!,
                                    ].join(' · '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.product.hasDiscount)
                                            Text(
                                              formatPrice(
                                                item.product.price *
                                                    item.quantity,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.grey,
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              ),
                                            ),
                                          Text(
                                            formatPrice(item.total),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      _RoundIconButton(
                                        icon: Icons.remove,
                                        onTap: () => cart.updateQuantity(
                                          item.key,
                                          item.quantity - 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(horizontal: 10),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      _RoundIconButton(
                                        icon: Icons.add,
                                        onTap: () => cart.updateQuantity(
                                          item.key,
                                          item.quantity + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => cart.removeItem(item.key),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border:
                          Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'المجموع',
                          value: formatPrice(cart.subtotal),
                        ),
                        if (cart.productsSaving > 0) ...[
                          const SizedBox(height: 4),
                          _SummaryRow(
                            label: 'وفّرت',
                            value:
                                '- ${formatPrice(cart.productsSaving)}',
                          ),
                        ],
                        if (cart.couponDiscount > 0) ...[
                          const SizedBox(height: 4),
                          _SummaryRow(
                            label: 'خصم الكوبون',
                            value:
                                '- ${formatPrice(cart.couponDiscount)}',
                          ),
                        ],
                        const SizedBox(height: 4),
                        _SummaryRow(
                          label: 'الشحن',
                          value: cart.shipping(settings) == 0
                              ? 'مجاني'
                              : formatPrice(cart.shipping(settings)),
                        ),
                        const Divider(height: 20),
                        _SummaryRow(
                          label: 'الإجمالي',
                          value: formatPrice(cart.total(settings)),
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'إتمام الطلب',
                          onPressed: () => _goToCheckout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontSize: bold ? 17 : 14,
      color: bold ? Colors.black : AppTheme.grey,
    );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style.copyWith(color: Colors.black)),
      ],
    );
  }
}
