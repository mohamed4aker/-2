import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../products/screens/customer_shell.dart';
import '../data/models/order.dart';

/// شاشة نجاح الطلب.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                'سيتم التواصل معك على ${order.phone} لتأكيد الطلب',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.grey, height: 2),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'متابعة التسوق',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const CustomerShell()),
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
