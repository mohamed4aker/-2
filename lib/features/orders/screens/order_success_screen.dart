import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../products/screens/customer_shell.dart';
import '../data/models/order.dart';
import 'receipt_screen.dart';

/// شاشة نجاح الطلب مع زر عرض الإيصال.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.check, color: Colors.white, size: 56),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'تم استلام طلبك بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'رقم الطلب: ${order.id}\n'
                'الإجمالي: ${formatPrice(order.total)}\n'
                '${order.isPaid ? "تم الدفع بنجاح ✅" : "سيتم التحصيل عند الاستلام"}\n'
                'هنتواصل معك على ${order.phone} لتأكيد الطلب',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.grey, height: 2),
              ),
              if (order.totalSaved > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '🎉 وفّرت ${formatPrice(order.totalSaved)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: 'عرض الإيصال',
                icon: Icons.receipt_long_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(order: order),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'متابعة التسوق',
                outlined: true,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const CustomerShell()),
                  (route) => false,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
