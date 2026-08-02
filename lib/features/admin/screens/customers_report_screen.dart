import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';

/// ملخص العميل الواحد.
class _CustomerSummary {
  _CustomerSummary({
    required this.name,
    required this.phone,
    required this.city,
  });

  final String name;
  final String phone;
  final String city;
  int orders = 0;
  double spent = 0;
  int items = 0;
  DateTime? lastOrder;

  double get average => orders == 0 ? 0 : spent / orders;
}

/// تقرير العملاء: الأكثر شراءً، المدن، ومعدل التكرار.
class CustomersReportScreen extends StatelessWidget {
  const CustomersReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context
        .watch<OrdersProvider>()
        .allOrders
        .where((o) => o.status != OrderStatus.cancelled)
        .toList();

    if (orders.isEmpty) {
      return const EmptyView(
        icon: Icons.people_outline,
        title: 'لا توجد بيانات عملاء بعد',
      );
    }

    // ---------- تجميع بيانات العملاء ----------
    final map = <String, _CustomerSummary>{};
    for (final order in orders) {
      final summary = map.putIfAbsent(
        order.phone,
        () => _CustomerSummary(
          name: order.customerName,
          phone: order.phone,
          city: order.city,
        ),
      );
      summary.orders += 1;
      summary.spent += order.total;
      summary.items += order.itemsCount;
      if (summary.lastOrder == null ||
          order.createdAt.isAfter(summary.lastOrder!)) {
        summary.lastOrder = order.createdAt;
      }
    }

    final customers = map.values.toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    final repeat = customers.where((c) => c.orders > 1).length;
    final repeatRate =
        customers.isEmpty ? 0.0 : (repeat / customers.length) * 100;

    // ---------- المدن ----------
    final cities = <String, int>{};
    for (final order in orders) {
      cities[order.city] = (cities[order.city] ?? 0) + 1;
    }
    final citiesSorted = cities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final guestOrders = orders.where((o) => o.isGuestOrder).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _Stat(
              title: 'إجمالي العملاء',
              value: '${customers.length}',
              icon: Icons.people_outline,
              dark: true,
            ),
            const SizedBox(width: 12),
            _Stat(
              title: 'عملاء متكررين',
              value: '$repeat (${repeatRate.toStringAsFixed(0)}%)',
              icon: Icons.repeat,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(
              title: 'طلبات الضيوف',
              value: '$guestOrders',
              icon: Icons.person_outline,
            ),
            const SizedBox(width: 12),
            _Stat(
              title: 'أعلى إنفاق',
              value: formatPrice(customers.first.spent),
              icon: Icons.star_outline,
              dark: true,
            ),
          ],
        ),

        const _Header('أفضل العملاء (حسب الإنفاق)'),
        ...customers.take(10).toList().asMap().entries.map(
          (entry) {
            final rank = entry.key + 1;
            final c = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rank <= 3 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${c.phone} · ${c.city}\n'
                  '${c.orders} طلب · ${c.items} قطعة · متوسط ${formatPrice(c.average)}',
                  style: const TextStyle(fontSize: 11, height: 1.6),
                ),
                isThreeLine: true,
                trailing: Text(
                  formatPrice(c.spent),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),

        const _Header('التوزيع الجغرافي'),
        ...citiesSorted.map((entry) {
          final ratio = entry.value / orders.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.value} طلب (${(ratio * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(
                        height: 10,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Container(
                        height: 10,
                        width: constraints.maxWidth * ratio,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                fontSize: 16,
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
