import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';

/// تقرير مبيعات مبسط: فترات + حالات الطلبات + الأكثر مبيعاً.
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  double _salesSince(List<Order> orders, DateTime since) => orders
      .where((o) =>
          o.status != OrderStatus.cancelled &&
          o.createdAt.isAfter(since))
      .fold(0, (sum, o) => sum + o.total);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.allOrders;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    // الأكثر مبيعاً (بالكمية).
    final Map<String, ({String name, int quantity, double revenue})> top =
        {};
    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        final current = top[item.productId];
        top[item.productId] = (
          name: item.name,
          quantity: (current?.quantity ?? 0) + item.quantity,
          revenue: (current?.revenue ?? 0) + item.total,
        );
      }
    }
    final topList = top.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final maxQuantity =
        topList.isEmpty ? 1 : topList.first.quantity;

    return RefreshIndicator(
      onRefresh: () => provider.loadAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'المبيعات حسب الفترة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _ReportRow(
            label: 'اليوم',
            value: formatPrice(_salesSince(orders, startOfToday)),
          ),
          _ReportRow(
            label: 'آخر 7 أيام',
            value: formatPrice(
              _salesSince(orders, now.subtract(const Duration(days: 7))),
            ),
          ),
          _ReportRow(
            label: 'آخر 30 يوم',
            value: formatPrice(
              _salesSince(orders, now.subtract(const Duration(days: 30))),
            ),
          ),
          _ReportRow(
            label: 'الإجمالي',
            value: formatPrice(provider.totalSales),
            highlighted: true,
          ),
          const SizedBox(height: 24),
          const Text(
            'الطلبات حسب الحالة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...OrderStatus.values.map(
            (status) => _ReportRow(
              label: status.labelAr,
              value: '${provider.byStatus(status).length} طلب',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'الأكثر مبيعاً',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (topList.isEmpty)
            const Text(
              'لا توجد مبيعات بعد',
              style: TextStyle(color: AppTheme.grey),
            )
          else
            ...topList.take(5).map(
              (entry) {
                final ratio = entry.quantity / maxQuantity;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.quantity} قطعة · ${formatPrice(entry.revenue)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // شريط بياني بسيط بالأبيض والأسود.
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
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? Colors.black : Colors.white,
        border: Border.all(
          color: highlighted ? Colors.black : AppTheme.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
