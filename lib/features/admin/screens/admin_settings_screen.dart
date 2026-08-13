import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../settings/data/models/payout_account.dart';
import '../../settings/providers/settings_provider.dart';
import 'admin_ticker_screen.dart';
import 'data_management_screen.dart';
import 'payout_settings_screen.dart';

/// إعدادات المتجر — تفتح وتقفل أي ميزة من هنا.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final s = provider.settings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---------- الشريط المتحرك ----------
        const _SectionHeader(
          title: 'الشريط المتحرك',
          subtitle: 'الشريط اللي بيلف في أعلى الصفحة الرئيسية',
          icon: Icons.campaign_outlined,
        ),
        _Toggle(
          title: 'تفعيل الشريط',
          subtitle: 'لو قفلته هيختفي تماماً من التطبيق',
          value: s.tickerEnabled,
          onChanged: (v) => provider.update(s.copyWith(tickerEnabled: v)),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: const Text('إدارة محتوى الشريط'),
          subtitle: Text('${s.tickerItems.length} عنصر — نصوص وصور'),
          trailing: const Icon(Icons.arrow_back_ios_new, size: 14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminTickerScreen()),
          ),
        ),
        _Stepper(
          label: 'مدة عرض كل عنصر',
          value: s.tickerSpeed,
          suffix: 'ثانية',
          min: 2,
          max: 15,
          onChanged: (v) => provider.update(s.copyWith(tickerSpeed: v)),
        ),

        // ---------- المنتجات المقترحة ----------
        const _SectionHeader(
          title: 'المنتجات المقترحة',
          subtitle: 'اقتراح قطع تكمّل الإطلالة في صفحة المنتج',
          icon: Icons.auto_awesome_outlined,
        ),
        _Toggle(
          title: 'تفعيل الاقتراحات',
          subtitle: 'قسم "كمّل إطلالتك" في صفحة المنتج',
          value: s.recommendationsEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(recommendationsEnabled: v)),
        ),
        _Toggle(
          title: 'اختيار تلقائي ذكي',
          subtitle: s.recommendationsAuto
              ? 'بيتعلم من الطلبات السابقة: إيه اللي بيتشرى مع بعض'
              : 'بيقترح المنتجات المميزة من التصنيفات المكمّلة بس',
          value: s.recommendationsAuto,
          enabled: s.recommendationsEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(recommendationsAuto: v)),
        ),

        // ---------- الإشعارات ----------
        const _SectionHeader(
          title: 'الإشعارات',
          subtitle: 'تنبيهات تظهر للعميل داخل التطبيق',
          icon: Icons.notifications_outlined,
        ),
        _Toggle(
          title: 'تفعيل الإشعارات',
          value: s.notificationsEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(notificationsEnabled: v)),
        ),
        _Toggle(
          title: 'إشعار المنتجات الجديدة',
          subtitle: 'يتنبّه العميل أول ما تضيف منتج جديد',
          value: s.notifyNewProducts,
          enabled: s.notificationsEnabled,
          onChanged: (v) => provider.update(s.copyWith(notifyNewProducts: v)),
        ),
        _Toggle(
          title: 'تذكير العميل الغايب',
          subtitle: 'رسالة ودّية لو بقاله فترة مفتحش التطبيق',
          value: s.notifyInactivity,
          enabled: s.notificationsEnabled,
          onChanged: (v) => provider.update(s.copyWith(notifyInactivity: v)),
        ),
        _Stepper(
          label: 'يعتبره غايب بعد',
          value: s.inactivityDays,
          suffix: 'يوم',
          min: 1,
          max: 30,
          enabled: s.notificationsEnabled && s.notifyInactivity,
          onChanged: (v) => provider.update(s.copyWith(inactivityDays: v)),
        ),

        // ---------- الطلب والدفع ----------
        const _SectionHeader(
          title: 'الطلب والدفع',
          subtitle: 'طرق الدخول وطرق الدفع المتاحة للعميل',
          icon: Icons.payments_outlined,
        ),
        _Toggle(
          title: 'الطلب كضيف',
          subtitle: 'العميل يقدر يطلب من غير ما يعمل حساب',
          value: s.guestCheckoutEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(guestCheckoutEnabled: v)),
        ),
        _Toggle(
          title: 'تسجيل الدخول بجوجل',
          value: s.googleSignInEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(googleSignInEnabled: v)),
        ),
        _Toggle(
          title: 'الدفع عند الاستلام',
          value: s.codEnabled,
          onChanged: (v) => provider.update(s.copyWith(codEnabled: v)),
        ),
        _Toggle(
          title: 'الدفع بالبطاقة (فيزا)',
          subtitle: 'يحتاج ربط حساب Paymob للتفعيل الحقيقي',
          value: s.cardPaymentEnabled,
          onChanged: (v) =>
              provider.update(s.copyWith(cardPaymentEnabled: v)),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: s.payout.isConfigured ? AppTheme.border : Colors.black,
              width: s.payout.isConfigured ? 1 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text(
              'حساب استلام الأموال',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            subtitle: Text(
              s.payout.isConfigured
                  ? '${s.payout.type.labelAr} · ${s.payout.summary}'
                  : '⚠️ حدد الحساب اللي هتستلم عليه فلوس الطلبات',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PayoutSettingsScreen(),
              ),
            ),
          ),
        ),

        // ---------- ميزات إضافية ----------
        const _SectionHeader(
          title: 'ميزات إضافية',
          icon: Icons.extension_outlined,
        ),
        _Toggle(
          title: 'تقييمات المنتجات',
          subtitle: 'العملاء يقيّموا المنتج ويكتبوا رأيهم',
          value: s.reviewsEnabled,
          onChanged: (v) => provider.update(s.copyWith(reviewsEnabled: v)),
        ),
        _Toggle(
          title: 'أكواد الخصم',
          subtitle: 'خانة كود الخصم في صفحة إتمام الطلب',
          value: s.couponsEnabled,
          onChanged: (v) => provider.update(s.copyWith(couponsEnabled: v)),
        ),

        // ---------- الشحن ----------
        const _SectionHeader(
          title: 'الشحن',
          icon: Icons.local_shipping_outlined,
        ),
        _NumberField(
          label: 'قيمة الشحن (ج.م)',
          value: s.shippingFee,
          onSubmitted: (v) => provider.update(s.copyWith(shippingFee: v)),
        ),
        _NumberField(
          label: 'شحن مجاني للطلبات فوق (ج.م)',
          value: s.freeShippingOver,
          onSubmitted: (v) =>
              provider.update(s.copyWith(freeShippingOver: v)),
        ),
        _Stepper(
          label: 'تنبيه المخزون لما يقل عن',
          value: s.lowStockThreshold,
          suffix: 'قطعة',
          min: 1,
          max: 50,
          onChanged: (v) =>
              provider.update(s.copyWith(lowStockThreshold: v)),
        ),

        // ---------- بيانات المتجر ----------
        const _SectionHeader(
          title: 'بيانات المتجر',
          subtitle: 'بتظهر في الإيصالات وشاشة الحساب',
          icon: Icons.storefront_outlined,
        ),
        _TextFieldTile(
          label: 'اسم المتجر',
          value: s.storeName,
          onSubmitted: (v) => provider.update(s.copyWith(storeName: v)),
        ),
        _TextFieldTile(
          label: 'رقم التواصل',
          value: s.storePhone,
          onSubmitted: (v) => provider.update(s.copyWith(storePhone: v)),
        ),
        _TextFieldTile(
          label: 'عنوان المتجر',
          value: s.storeAddress,
          onSubmitted: (v) => provider.update(s.copyWith(storeAddress: v)),
        ),

        // ---------- إدارة البيانات ----------
        const _SectionHeader(
          title: 'إدارة البيانات',
          subtitle: 'تصفير البيانات التجريبية قبل الإطلاق',
          icon: Icons.storage_outlined,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text(
              'مسح البيانات التجريبية',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            subtitle: const Text(
              'امسح المنتجات والطلبات التجريبية وابدأ ببياناتك',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DataManagementScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Moda v${AppConfig.appVersion}',
            style: const TextStyle(fontSize: 11, color: AppTheme.grey),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: enabled ? Colors.black : Colors.black38,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: enabled ? AppTheme.grey : Colors.black26,
              ),
            ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.suffix,
    required this.min,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final int value;
  final String suffix;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: enabled ? Colors.black : Colors.black38,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed:
                enabled && value > min ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value $suffix',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed:
                enabled && value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final double value;
  final ValueChanged<double> onSubmitted;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final parsed = double.tryParse(_controller.text.trim());
              if (parsed != null) {
                widget.onSubmitted(parsed);
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحفظ')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _TextFieldTile extends StatefulWidget {
  const _TextFieldTile({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSubmitted;

  @override
  State<_TextFieldTile> createState() => _TextFieldTileState();
}

class _TextFieldTileState extends State<_TextFieldTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                widget.onSubmitted(text);
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحفظ')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
