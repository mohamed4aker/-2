import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/product_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../data/models/order.dart';
import '../providers/orders_provider.dart';

/// طلبات العميل مع متابعة حالة كل طلب.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String? _loadedForUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.watch<AuthProvider>().user?.id;
    if (userId != null && userId != _loadedForUserId) {
      _loadedForUserId = userId;
      // تحميل الطلبات بعد اكتمال بناء الشاشة.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<OrdersProvider>().loadMine(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: !auth.isLoggedIn
          ? EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'سجلي الدخول لعرض طلباتك',
              action: AppButton(
                label: 'تسجيل الدخول',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            )
          : orders.loading
              ? const Center(child: CircularProgressIndicator())
              : orders.myOrders.isEmpty
                  ? const EmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد طلبات بعد',
                      subtitle: 'ابدئي التسوق وسيظهر طلبك هنا',
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          orders.loadMine(auth.user!.id),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.myOrders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _OrderCard(order: orders.myOrders[index]),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          title: Row(
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              OrderStatusChip(status: order.status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${formatDate(order.createdAt)} · ${order.itemsCount} قطعة · ${formatPrice(order.total)}',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
          ),
          children: [
            const Divider(height: 1, color: AppTheme.border),
            _StatusTimeline(status: order.status),
            const Divider(height: 1, color: AppTheme.border),
            ...order.items.map(
              (item) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    path: item.image,
                    width: 48,
                    height: 48,
                  ),
                ),
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  [
                    if (item.size != null) 'مقاس ${item.size}',
                    if (item.color != null) item.color!,
                    '× ${item.quantity}',
                  ].join(' · '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  formatPrice(item.total),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// شارة حالة الطلب (أبيض وأسود).
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final filled = status != OrderStatus.cancelled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          color: filled ? Colors.white : Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'تم إلغاء هذا الطلب',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    final currentIndex = _steps.indexOf(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? Colors.black : Colors.black26,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final reached = stepIndex <= currentIndex;
          return Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: reached ? Colors.black : Colors.white,
                  border: Border.all(color: Colors.black),
                  shape: BoxShape.circle,
                ),
                child: reached
                    ? const Icon(Icons.check,
                        size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                _steps[stepIndex].labelAr,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      reached ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
