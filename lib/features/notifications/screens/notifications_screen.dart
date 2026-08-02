import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_view.dart';
import '../../products/screens/product_details_screen.dart';
import '../data/models/app_notification.dart';
import '../providers/notifications_provider.dart';

/// مركز الإشعارات للعميل.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) => switch (type) {
        NotificationType.newProduct => Icons.new_releases_outlined,
        NotificationType.offer => Icons.local_offer_outlined,
        NotificationType.orderStatus => Icons.local_shipping_outlined,
        NotificationType.reminder => Icons.favorite_border,
        NotificationType.general => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (items.isNotEmpty) ...[
            IconButton(
              tooltip: 'تعليم الكل كمقروء',
              icon: const Icon(Icons.done_all),
              onPressed: provider.markAllRead,
            ),
            IconButton(
              tooltip: 'مسح الكل',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: provider.clear,
            ),
          ],
        ],
      ),
      body: items.isEmpty
          ? const EmptyView(
              icon: Icons.notifications_none,
              title: 'مفيش إشعارات',
              subtitle: 'هنبلغك أول ما ينزل جديد أو يتغيّر حال طلبك',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: item.read ? Colors.white : AppTheme.lightGrey,
                    border: Border.all(
                      color: item.read ? AppTheme.border : Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      provider.markRead(item.id);
                      if (item.productId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                              productId: item.productId!,
                            ),
                          ),
                        );
                      }
                    },
                    leading: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconFor(item.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight:
                            item.read ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${item.body}\n${formatDate(item.createdAt)}',
                      style: const TextStyle(fontSize: 12, height: 1.6),
                    ),
                    isThreeLine: true,
                    trailing: item.read
                        ? null
                        : Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
