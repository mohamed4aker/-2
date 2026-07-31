import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../data/models/order.dart';
import 'order_success_screen.dart';

/// شاشة مؤقتة للدفع الإلكتروني — سيتم استبدالها بتكامل Paymob لاحقاً.
class OnlinePaymentScreen extends StatelessWidget {
  const OnlinePaymentScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدفع الإلكتروني')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.credit_card, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'الدفع الإلكتروني قادم قريباً',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'جاري العمل على تفعيل الدفع بالبطاقات البنكية والمحافظ '
                'الإلكترونية عبر بوابة Paymob.\n'
                'تم تسجيل طلبك وسيتم تحصيل المبلغ عند الاستلام.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grey, height: 1.8),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('رقم الطلب: ${order.id}'),
                    Text(
                      formatPrice(order.total),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'متابعة',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OrderSuccessScreen(order: order),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
