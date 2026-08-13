import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/providers/orders_provider.dart';
import '../../products/data/product_repository.dart';
import '../../products/providers/products_provider.dart';
import '../../products/providers/reviews_provider.dart';

/// إدارة البيانات — تصفير البيانات التجريبية قبل الإطلاق.
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _working = false;

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'تأكيد المسح',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _clearProducts() async {
    if (!await _confirm(
      'مسح كل المنتجات',
      'هيتم حذف كل المنتجات نهائياً. متأكد؟',
    )) {
      return;
    }
    setState(() => _working = true);
    await MockProductRepository.clearAll();
    if (!mounted) return;
    await context.read<ProductsProvider>().load(force: true);
    if (!mounted) return;
    setState(() => _working = false);
    _done('تم مسح كل المنتجات');
  }

  Future<void> _clearOrders() async {
    if (!await _confirm(
      'مسح كل الطلبات',
      'هيتم حذف كل الطلبات وتصفير التقارير. متأكد؟',
    )) {
      return;
    }
    setState(() => _working = true);
    await MockOrderRepository.clearAll();
    if (!mounted) return;
    await context.read<OrdersProvider>().loadAll();
    if (!mounted) return;
    setState(() => _working = false);
    _done('تم مسح كل الطلبات');
  }

  Future<void> _clearEverything() async {
    if (!await _confirm(
      'تصفير التطبيق بالكامل',
      'هيتم حذف كل المنتجات والطلبات والتقييمات والإشعارات. '
      'العملية دي مش ممكن التراجع عنها — متأكد؟',
    )) {
      return;
    }
    setState(() => _working = true);
    await MockProductRepository.clearAll();
    await MockOrderRepository.clearAll();
    if (!mounted) return;
    await context.read<ReviewsProvider>().clearAll();
    if (!mounted) return;
    await context.read<NotificationsProvider>().clear();
    if (!mounted) return;
    await context.read<ProductsProvider>().load(force: true);
    if (!mounted) return;
    await context.read<OrdersProvider>().loadAll();
    if (!mounted) return;
    setState(() => _working = false);
    _done('تم تصفير التطبيق — جاهز لبياناتك الحقيقية');
  }

  void _done(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final orders = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة البيانات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppConfig.useDemoData
                          ? Icons.science_outlined
                          : Icons.verified_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppConfig.useDemoData
                          ? 'التطبيق في وضع التجربة'
                          : 'التطبيق في وضع الإنتاج',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppConfig.useDemoData
                      ? 'البيانات الحالية تجريبية للعرض. قبل الرفع على '
                          'جوجل بلاي: امسح البيانات من هنا، وغيّر '
                          'useDemoData لـ false في ملف '
                          'lib/core/config/app_config.dart'
                      : 'البيانات التجريبية متوقفة. أي منتجات تضيفها هي '
                          'بيانات حقيقية.',
                  style: const TextStyle(fontSize: 12, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _StatLine(
            label: 'عدد المنتجات الحالية',
            value: '${products.products.length}',
          ),
          _StatLine(
            label: 'عدد التصنيفات',
            value: '${products.categories.length}',
          ),
          _StatLine(
            label: 'عدد الطلبات',
            value: '${orders.allOrders.length}',
          ),

          const SizedBox(height: 24),
          const Text(
            'مسح البيانات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          AppButton(
            label: 'مسح كل المنتجات',
            icon: Icons.inventory_2_outlined,
            outlined: true,
            loading: _working,
            onPressed: _clearProducts,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'مسح كل الطلبات',
            icon: Icons.receipt_long_outlined,
            outlined: true,
            loading: _working,
            onPressed: _clearOrders,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'تصفير التطبيق بالكامل',
            icon: Icons.delete_forever_outlined,
            loading: _working,
            onPressed: _clearEverything,
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ ملاحظة مهمة جداً',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'البيانات محفوظة على الجهاز ده بس. المنتجات اللي بتضيفها '
                  'من موبايلك مش هتظهر لعملاء تانيين على موبايلاتهم.\n\n'
                  'عشان يكون عندك متجر حقيقي كل العملاء يشوفوا نفس المنتجات، '
                  'لازم تربط التطبيق بسيرفر (باك اند). الخطوات في ملف README '
                  'تحت عنوان "الربط بالباك اند".',
                  style: TextStyle(fontSize: 12, height: 1.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
