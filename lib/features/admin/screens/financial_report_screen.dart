import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';

/// التقرير المالي: الإيرادات، المحصّل، المستحق، وطرق الدفع.
class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.allOrders
        .where((o) => o.status != OrderStatus.cancelled)
        .toList();
    final now = DateTime.now();

    final cod = orders
        .where((o) => o.paymentMethod == PaymentMethod.cashOnDelivery)
        .toList();
    final card =
        orders.where((o) => o.paymentMethod == PaymentMethod.card).toList();

    final cancelled = provider.allOrders
        .where((o) => o.status == OrderStatus.cancelled)
        .toList();
    final lostRevenue =
        cancelled.fold<double>(0, (sum, o) => sum + o.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---------- الملخص المالي ----------
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'إجمالي الإيرادات',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                formatPrice(provider.totalSales),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'محصّل',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatPrice(provider.collectedRevenue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 34, color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'مستحق',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatPrice(provider.pendingRevenue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ---------- المبيعات حسب الفترة ----------
        const _Header('المبيعات حسب الفترة'),
        _Line(
          label: 'اليوم',
          value: formatPrice(provider.todaySales),
        ),
        _Line(
          label: 'آخر ٧ أيام',
          value: formatPrice(
            provider.salesSince(now.subtract(const Duration(days: 7))),
          ),
        ),
        _Line(
          label: 'آخر ٣٠ يوم',
          value: formatPrice(
            provider.salesSince(now.subtract(const Duration(days: 30))),
          ),
        ),
        _Line(
          label: 'الإجمالي',
          value: formatPrice(provider.totalSales),
          highlighted: true,
        ),

        // ---------- مؤشرات الأداء ----------
        const _Header('مؤشرات الأداء'),
        _Line(
          label: 'متوسط قيمة الطلب',
          value: formatPrice(provider.averageOrderValue),
        ),
        _Line(
          label: 'عدد الطلبات',
          value: '${orders.length} طلب',
        ),
        _Line(
          label: 'عدد القطع المباعة',
          value: '${provider.totalItemsSold} قطعة',
        ),
        _Line(
          label: 'عدد العملاء',
          value: '${provider.uniqueCustomers} عميل',
        ),
        _Line(
          label: 'إجمالي الشحن المحصّل',
          value: formatPrice(provider.totalShipping),
        ),
        _Line(
          label: 'إجمالي الخصومات الممنوحة',
          value: formatPrice(provider.totalDiscounts),
        ),

        // ---------- طرق الدفع ----------
        const _Header('طرق الدفع'),
        _PaymentBar(
          label: 'الدفع عند الاستلام',
          count: cod.length,
          amount: cod.fold<double>(0, (s, o) => s + o.total),
          total: orders.length,
        ),
        _PaymentBar(
          label: 'بطاقة بنكية',
          count: card.length,
          amount: card.fold<double>(0, (s, o) => s + o.total),
          total: orders.length,
        ),

        // ---------- الخسائر ----------
        const _Header('الطلبات الملغية'),
        _Line(label: 'عدد الطلبات الملغية', value: '${cancelled.length}'),
        _Line(
          label: 'قيمة المبيعات الضائعة',
          value: formatPrice(lostRevenue),
        ),
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

class _Line extends StatelessWidget {
  const _Line({
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
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({
    required this.label,
    required this.count,
    required this.amount,
    required this.total,
  });

  final String label;
  final int count;
  final double amount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '$count طلب · ${formatPrice(amount)}',
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
          const SizedBox(height: 4),
          Text(
            '${(ratio * 100).toStringAsFixed(0)}% من الطلبات',
            style: const TextStyle(fontSize: 11, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }
}
