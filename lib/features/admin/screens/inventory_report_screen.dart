import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/product_image.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../products/data/models/product.dart';
import '../../products/providers/products_provider.dart';
import '../../settings/providers/settings_provider.dart';

/// تقرير المخزن: قيمة البضاعة، نواقص، منتجات راكدة، وحركة البيع.
class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final orders = context.watch<OrdersProvider>();
    final threshold =
        context.watch<SettingsProvider>().settings.lowStockThreshold;

    final all = products.products;

    // ---------- حسابات المخزن ----------
    final totalUnits = all.fold<int>(0, (sum, p) => sum + p.stock);
    final stockValue =
        all.fold<double>(0, (sum, p) => sum + (p.finalPrice * p.stock));
    final outOfStock = all.where((p) => p.stock == 0).toList();
    final lowStock =
        all.where((p) => p.stock > 0 && p.stock <= threshold).toList();

    // كمية مباعة لكل منتج
    final sold = <String, int>{};
    for (final order in orders.allOrders) {
      if (order.status == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        sold[item.productId] = (sold[item.productId] ?? 0) + item.quantity;
      }
    }

    // منتجات راكدة: متوفرة بكمية كويسة ومحدش اشتراها
    final stagnant = all
        .where((p) => p.stock > 0 && (sold[p.id] ?? 0) == 0)
        .toList()
      ..sort((a, b) => b.stock.compareTo(a.stock));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _Stat(
              title: 'قيمة المخزن',
              value: formatPrice(stockValue),
              icon: Icons.inventory_2_outlined,
              dark: true,
            ),
            const SizedBox(width: 12),
            _Stat(
              title: 'إجمالي القطع',
              value: '$totalUnits قطعة',
              icon: Icons.widgets_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(
              title: 'أصناف نفدت',
              value: '${outOfStock.length}',
              icon: Icons.remove_shopping_cart_outlined,
            ),
            const SizedBox(width: 12),
            _Stat(
              title: 'أصناف قاربت',
              value: '${lowStock.length}',
              icon: Icons.warning_amber_outlined,
              dark: true,
            ),
          ],
        ),

        if (outOfStock.isNotEmpty) ...[
          const _Header(title: 'نفدت الكمية — محتاجة تجديد فوراً', icon: '🔴'),
          ...outOfStock.map((p) => _ProductRow(
                product: p,
                trailing: 'نفد',
                soldCount: sold[p.id] ?? 0,
              )),
        ],

        if (lowStock.isNotEmpty) ...[
          const _Header(title: 'كمية قليلة', icon: '🟡'),
          ...lowStock.map((p) => _ProductRow(
                product: p,
                trailing: 'باقي ${p.stock}',
                soldCount: sold[p.id] ?? 0,
              )),
        ],

        if (stagnant.isNotEmpty) ...[
          const _Header(
            title: 'بضاعة راكدة — متباعتش ولا مرة',
            icon: '📦',
          ),
          ...stagnant.take(10).map((p) => _ProductRow(
                product: p,
                trailing: '${p.stock} في المخزن',
                soldCount: 0,
              )),
        ],

        const _Header(title: 'كل المنتجات حسب المخزون', icon: '📋'),
        ...(List<Product>.of(all)
              ..sort((a, b) => a.stock.compareTo(b.stock)))
            .map((p) => _ProductRow(
                  product: p,
                  trailing: '${p.stock}',
                  soldCount: sold[p.id] ?? 0,
                )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        '$icon  $title',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.trailing,
    required this.soldCount,
  });

  final Product product;
  final String trailing;
  final int soldCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: product.stock == 0 ? Colors.black : AppTheme.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: ProductImage(
            path: product.mainImage,
            width: 42,
            height: 42,
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          'اتباع منها $soldCount · قيمة المتاح '
          '${formatPrice(product.finalPrice * product.stock)}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          trailing,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.title,
    required this.value,
    required this.icon,
    this.dark = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: dark ? Colors.white : Colors.black, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: dark ? Colors.white70 : AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
