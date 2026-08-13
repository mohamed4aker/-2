import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/repository_factory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/product_image.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/my_orders_screen.dart' show OrderStatusChip;
import '../../products/providers/products_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'admin_order_details_screen.dart';

/// لوحة التحكم: إحصائيات + تنبيه المخزون المنخفض + أحدث الطلبات.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final products = context.watch<ProductsProvider>();
    final threshold =
        context.watch<SettingsProvider>().settings.lowStockThreshold;
    final lowStock = products.lowStockBelow(threshold);
    final recentOrders = orders.allOrders.take(5).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          orders.loadAll(),
          products.load(force: true),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- حالة الاتصال بالسيرفر ----------
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color:
                  RepositoryFactory.isOnline ? Colors.black : Colors.white,
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  RepositoryFactory.isOnline
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  size: 20,
                  color: RepositoryFactory.isOnline
                      ? Colors.white
                      : Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    RepositoryFactory.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: RepositoryFactory.isOnline
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _StatCard(
                title: 'إجمالي الطلبات',
                value: '${orders.totalOrders}',
                icon: Icons.receipt_long_outlined,
                dark: true,
              ),
              const SizedBox(width: 12),
              _StatCard(
                title: 'طلبات جديدة',
                value: '${orders.pendingCount}',
                icon: Icons.fiber_new_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                title: 'مبيعات اليوم',
                value: formatPrice(orders.todaySales),
                icon: Icons.today_outlined,
              ),
              const SizedBox(width: 12),
              _StatCard(
                title: 'إجمالي المبيعات',
                value: formatPrice(orders.totalSales),
                icon: Icons.attach_money,
                dark: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // تنبيهات المخزون
          Row(
            children: [
              const Icon(Icons.warning_amber_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'تنبيه المخزون المنخفض (${lowStock.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (lowStock.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'كل المنتجات متوفرة بكميات جيدة',
                style: TextStyle(color: AppTheme.grey),
              ),
            )
          else
            ...lowStock.map(
              (product) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      path: product.mainImage,
                      width: 44,
                      height: 44,
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Text(
                    product.stock == 0
                        ? 'نفدت'
                        : 'باقي ${product.stock}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'أحدث الطلبات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (recentOrders.isEmpty)
            const Text(
              'لا توجد طلبات بعد',
              style: TextStyle(color: AppTheme.grey),
            )
          else
            ...recentOrders.map(
              (order) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminOrderDetailsScreen(orderId: order.id),
                    ),
                  ),
                  title: Text(
                    '${order.id} · ${order.customerName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${formatDate(order.createdAt)} · ${formatPrice(order.total)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: OrderStatusChip(status: order.status),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
            Icon(icon, color: dark ? Colors.white : Colors.black),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: dark ? Colors.white70 : AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
