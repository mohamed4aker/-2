import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/product_image.dart';
import '../../notifications/data/models/app_notification.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../orders/data/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/my_orders_screen.dart' show OrderStatusChip;
import '../../orders/screens/receipt_screen.dart';

/// تفاصيل الطلب للأدمن: بيانات العميل + المنتجات + تغيير الحالة + الإيصال.
class AdminOrderDetailsScreen extends StatelessWidget {
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  Future<void> _changeStatus(
    BuildContext context,
    Order order,
    OrderStatus status,
  ) async {
    await context.read<OrdersProvider>().updateStatus(order.id, status);
    if (!context.mounted) return;

    // إشعار للعميل بتغيّر حالة الطلب.
    await context.read<NotificationsProvider>().push(
          title: 'تحديث على طلبك',
          body: 'الطلب ${order.id} أصبح "${status.labelAr}"',
          type: NotificationType.orderStatus,
          orderId: order.id,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تغيير الحالة إلى "${status.labelAr}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order = provider.orderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('الطلب غير موجود')),
      );
    }
    final currentOrder = order;

    return Scaffold(
      appBar: AppBar(
        title: Text('طلب ${currentOrder.id}'),
        actions: [
          IconButton(
            tooltip: 'إيصال المتجر',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(
                  order: currentOrder,
                  copy: ReceiptCopy.merchant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text(
                'حالة الطلب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              OrderStatusChip(status: currentOrder.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OrderStatus.values
                .map(
                  (status) => ChoiceChip(
                    label: Text(status.labelAr),
                    selected: currentOrder.status == status,
                    onSelected: currentOrder.status == status
                        ? null
                        : (_) => _changeStatus(context, currentOrder, status),
                  ),
                )
                .toList(),
          ),

          const Divider(height: 32),
          const Text(
            'بيانات العميل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'الاسم',
                  value: currentOrder.customerName,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'الهاتف',
                  value: currentOrder.phone,
                  copyable: true,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'العنوان',
                  value: currentOrder.address,
                  copyable: true,
                ),
                _InfoRow(
                  icon: Icons.location_city_outlined,
                  label: 'المدينة',
                  value: currentOrder.city,
                ),
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'الدفع',
                  value: currentOrder.paymentMethod.labelAr,
                ),
                _InfoRow(
                  icon: Icons.verified_outlined,
                  label: 'حالة الدفع',
                  value: currentOrder.paymentStatus.labelAr,
                ),
                if (currentOrder.transactionId != null)
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'رقم العملية',
                    value: currentOrder.transactionId!,
                  ),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'التاريخ',
                  value: formatDate(currentOrder.createdAt),
                ),
                if (currentOrder.notes != null)
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'ملاحظات',
                    value: currentOrder.notes!,
                  ),
                if (currentOrder.isGuestOrder)
                  const _InfoRow(
                    icon: Icons.info_outline,
                    label: 'نوع الطلب',
                    value: 'طلب ضيف (بدون حساب)',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'المنتجات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...currentOrder.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
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
                _MoneyRow(
                  label: 'المجموع',
                  value: formatPrice(currentOrder.subtotal),
                ),
                if (currentOrder.discount > 0)
                  _MoneyRow(
                    label: 'خصم (${currentOrder.couponCode ?? ""})',
                    value: '- ${formatPrice(currentOrder.discount)}',
                  ),
                _MoneyRow(
                  label: 'الشحن',
                  value: currentOrder.shipping == 0
                      ? 'مجاني'
                      : formatPrice(currentOrder.shipping),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'الإجمالي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  formatPrice(currentOrder.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'عرض إيصال المتجر',
            icon: Icons.receipt_long_outlined,
            outlined: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(
                  order: currentOrder,
                  copy: ReceiptCopy.merchant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'عرض نسخة العميل',
            icon: Icons.person_outline,
            outlined: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(order: currentOrder),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(color: AppTheme.grey, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          if (copyable)
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم نسخ $label')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy, size: 15),
              ),
            ),
        ],
      ),
    );
  }
}
