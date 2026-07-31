import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/my_orders_screen.dart' show OrderStatusChip;
import 'admin_order_details_screen.dart';

/// إدارة الطلبات مع الفلترة بالحالة.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.byStatus(_filter);

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text('الكل (${provider.allOrders.length})'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              ...OrderStatus.values.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${status.labelAr} (${provider.byStatus(status).length})',
                    ),
                    selected: _filter == status,
                    onSelected: (_) => setState(() => _filter = status),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? const EmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد طلبات بهذه الحالة',
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.loadAll(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminOrderDetailsScreen(
                                    orderId: order.id,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${order.id} · ${order.customerName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${formatDate(order.createdAt)}\n'
                                '${order.city} · ${order.itemsCount} قطعة · ${formatPrice(order.total)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                              isThreeLine: true,
                              trailing:
                                  OrderStatusChip(status: order.status),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
