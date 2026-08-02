import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/models/order.dart';

/// نسخة الإيصال: نسخة العميل أو نسخة المتجر.
enum ReceiptCopy { customer, merchant }

/// إيصال الطلب — بيتعرض للعميل بعد الدفع وللمتجر في تفاصيل الطلب.
///
/// نسخة العميل: فيها تفاصيل المنتجات والمبلغ وبيانات التواصل.
/// نسخة المتجر: زيادة عليها بيانات التوصيل الكاملة وحالة الدفع
/// وملاحظات التجهيز.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    required this.order,
    this.copy = ReceiptCopy.customer,
  });

  final Order order;
  final ReceiptCopy copy;

  bool get isMerchant => copy == ReceiptCopy.merchant;

  String _asText(String storeName, String storePhone) {
    final buffer = StringBuffer()
      ..writeln('=========================')
      ..writeln('        $storeName')
      ..writeln(isMerchant ? '   نسخة المتجر' : '   نسخة العميل')
      ..writeln('=========================')
      ..writeln('رقم الطلب: ${order.id}')
      ..writeln('التاريخ: ${formatDate(order.createdAt)}')
      ..writeln('-------------------------');

    for (final item in order.items) {
      buffer.writeln('${item.name}');
      final details = [
        if (item.size != null) 'مقاس ${item.size}',
        if (item.color != null) item.color!,
      ].join(' · ');
      if (details.isNotEmpty) buffer.writeln('  ($details)');
      buffer.writeln(
        '  ${item.quantity} × ${formatPrice(item.price)} = ${formatPrice(item.total)}',
      );
    }

    buffer
      ..writeln('-------------------------')
      ..writeln('المجموع: ${formatPrice(order.subtotal)}');
    if (order.discount > 0) {
      buffer.writeln(
        'خصم الكوبون (${order.couponCode}): -${formatPrice(order.discount)}',
      );
    }
    buffer
      ..writeln(
        'الشحن: ${order.shipping == 0 ? "مجاني" : formatPrice(order.shipping)}',
      )
      ..writeln('الإجمالي: ${formatPrice(order.total)}')
      ..writeln('-------------------------')
      ..writeln('طريقة الدفع: ${order.paymentMethod.labelAr}')
      ..writeln('حالة الدفع: ${order.paymentStatus.labelAr}');

    if (isMerchant) {
      buffer
        ..writeln('-------------------------')
        ..writeln('العميل: ${order.customerName}')
        ..writeln('الهاتف: ${order.phone}')
        ..writeln('العنوان: ${order.address}')
        ..writeln('المدينة: ${order.city}')
        ..writeln('حالة الطلب: ${order.status.labelAr}');
      if (order.isGuestOrder) buffer.writeln('طلب ضيف (بدون حساب)');
    } else {
      buffer
        ..writeln('-------------------------')
        ..writeln('شكراً لثقتك 🖤')
        ..writeln('للاستفسار: $storePhone');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMerchant ? 'إيصال المتجر' : 'إيصال الطلب'),
        actions: [
          IconButton(
            tooltip: 'نسخ الإيصال',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(
                text: _asText(settings.storeName, settings.storePhone),
              ));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ الإيصال — تقدر تبعته واتساب'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Column(
              children: [
                // ---------- ترويسة ----------
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      Text(
                        settings.storeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMerchant ? 'نسخة المتجر' : 'نسخة العميل',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Row(label: 'رقم الطلب', value: order.id, bold: true),
                      _Row(
                        label: 'التاريخ',
                        value: formatDate(order.createdAt),
                      ),
                      if (order.transactionId != null)
                        _Row(
                          label: 'رقم العملية',
                          value: order.transactionId!,
                        ),
                      const _Dashed(),

                      // ---------- المنتجات ----------
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              if (item.size != null || item.color != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    [
                                      if (item.size != null)
                                        'مقاس ${item.size}',
                                      if (item.color != null) item.color!,
                                    ].join(' · '),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${item.quantity} × ',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (item.hadDiscount) ...[
                                    Text(
                                      formatPrice(item.originalPrice!),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.grey,
                                        decoration:
                                            TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    formatPrice(item.price),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatPrice(item.total),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const _Dashed(),
                      _Row(
                        label: 'المجموع',
                        value: formatPrice(order.subtotal),
                      ),
                      if (order.discount > 0)
                        _Row(
                          label: 'خصم الكوبون (${order.couponCode ?? ""})',
                          value: '- ${formatPrice(order.discount)}',
                        ),
                      _Row(
                        label: 'الشحن',
                        value: order.shipping == 0
                            ? 'مجاني'
                            : formatPrice(order.shipping),
                      ),
                      const _Dashed(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        color: Colors.black,
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
                              formatPrice(order.total),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.totalSaved > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '🎉 وفّرت ${formatPrice(order.totalSaved)} في الطلب ده',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _Row(
                        label: 'طريقة الدفع',
                        value: order.paymentMethod.labelAr,
                      ),
                      _Row(
                        label: 'حالة الدفع',
                        value: order.paymentStatus.labelAr,
                        bold: true,
                      ),

                      // ---------- بيانات إضافية لنسخة المتجر ----------
                      if (isMerchant) ...[
                        const _Dashed(),
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            'بيانات التوصيل',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _Row(label: 'العميل', value: order.customerName),
                        _Row(label: 'الهاتف', value: order.phone),
                        _Row(label: 'العنوان', value: order.address),
                        _Row(label: 'المدينة', value: order.city),
                        _Row(
                          label: 'حالة الطلب',
                          value: order.status.labelAr,
                          bold: true,
                        ),
                        _Row(
                          label: 'عدد القطع',
                          value: '${order.itemsCount}',
                        ),
                        if (order.isGuestOrder)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '⚠️ طلب ضيف — بدون حساب مسجّل',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ] else ...[
                        const _Dashed(),
                        Text(
                          'شكراً لثقتك 🖤',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'للاستفسار: ${settings.storePhone}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // باركود شكلي بسيط بالأبيض والأسود
                      _FakeBarcode(seed: order.id),
                      const SizedBox(height: 6),
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'نسخ الإيصال كنص',
            icon: Icons.copy_all_outlined,
            outlined: true,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(
                text: _asText(settings.storeName, settings.storePhone),
              ));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الإيصال')),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 8).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(width: 4, height: 1, color: Colors.black26),
            ),
          );
        },
      ),
    );
  }
}

/// باركود شكلي (زخرفة فقط) مبني من حروف رقم الطلب.
class _FakeBarcode extends StatelessWidget {
  const _FakeBarcode({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final codes = seed.codeUnits;
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(48, (i) {
          final unit = codes[i % codes.length];
          final wide = (unit + i) % 3 == 0;
          final visible = (unit + i) % 4 != 0;
          return Container(
            width: wide ? 3 : 1.5,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: visible ? Colors.black : Colors.transparent,
          );
        }),
      ),
    );
  }
}
