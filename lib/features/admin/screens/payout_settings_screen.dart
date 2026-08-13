import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../settings/data/models/payout_account.dart';
import '../../settings/providers/settings_provider.dart';

/// شاشة حساب استلام الأموال — فين فلوس الطلبات المدفوعة بالبطاقة بتروح.
class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late PayoutType _type;
  late final TextEditingController _holder;
  late final TextEditingController _bank;
  late final TextEditingController _account;
  late final TextEditingController _iban;
  late final TextEditingController _wallet;
  late final TextEditingController _instapay;
  late final TextEditingController _merchantId;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final p = context.read<SettingsProvider>().settings.payout;
    _type = p.type;
    _holder = TextEditingController(text: p.holderName);
    _bank = TextEditingController(text: p.bankName);
    _account = TextEditingController(text: p.accountNumber);
    _iban = TextEditingController(text: p.iban);
    _wallet = TextEditingController(text: p.walletNumber);
    _instapay = TextEditingController(text: p.instapayAddress);
    _merchantId = TextEditingController(text: p.merchantId);
    _notes = TextEditingController(text: p.notes);
  }

  @override
  void dispose() {
    for (final c in [
      _holder,
      _bank,
      _account,
      _iban,
      _wallet,
      _instapay,
      _merchantId,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SettingsProvider>();
    await provider.update(
      provider.settings.copyWith(
        payout: PayoutAccount(
          type: _type,
          holderName: _holder.text.trim(),
          bankName: _bank.text.trim(),
          accountNumber: _account.text.trim(),
          iban: _iban.text.trim(),
          walletNumber: _wallet.text.trim(),
          instapayAddress: _instapay.text.trim(),
          merchantId: _merchantId.text.trim(),
          notes: _notes.text.trim(),
        ),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ بيانات الحساب ✅')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب استلام الأموال')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- تنبيه توضيحي مهم ----------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'اقرأ ده الأول',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'التحويل الفعلي للفلوس بيتم من بوابة الدفع (Paymob) '
                    'على الحساب المسجّل عندهم في لوحة التاجر بتاعتك.\n\n'
                    'البيانات اللي هنا للتوثيق والمراجعة عشان تفضل قدامك '
                    'وتتأكد إنها مطابقة للمسجّل في Paymob.',
                    style: TextStyle(fontSize: 12, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------- نوع الحساب ----------
            const Text(
              'طريقة الاستلام',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PayoutType.values
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t.labelAr),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'اسم صاحب الحساب (زي ما هو في البنك)',
              controller: _holder,
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'أدخل اسم صاحب الحساب'
                  : null,
            ),
            const SizedBox(height: 12),

            // ---------- حقول حسب النوع ----------
            if (_type == PayoutType.bank) ...[
              AppTextField(
                label: 'اسم البنك',
                controller: _bank,
                icon: Icons.account_balance_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'أدخل اسم البنك'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'رقم الحساب',
                controller: _account,
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'IBAN (اختياري)',
                controller: _iban,
                icon: Icons.credit_card_outlined,
                textDirection: TextDirection.ltr,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return null;
                  if (value.length < 15) return 'IBAN غير مكتمل';
                  return null;
                },
              ),
            ] else if (_type == PayoutType.wallet) ...[
              AppTextField(
                label: 'رقم المحفظة (فودافون/اتصالات/أورنج كاش)',
                controller: _wallet,
                icon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'أدخل رقم محفظة صحيح'
                    : null,
              ),
            ] else ...[
              AppTextField(
                label: 'عنوان إنستاباي (مثال: name@instapay)',
                controller: _instapay,
                icon: Icons.alternate_email,
                textDirection: TextDirection.ltr,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'أدخل عنوان إنستاباي صحيح'
                    : null,
              ),
            ],

            const SizedBox(height: 20),
            AppTextField(
              label: 'رقم التاجر عند بوابة الدفع (اختياري)',
              controller: _merchantId,
              icon: Icons.storefront_outlined,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'ملاحظات (اختياري)',
              controller: _notes,
              icon: Icons.notes_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            // ---------- حالة ربط البوابة ----------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    ApiConfig.isPaymobConfigured
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ApiConfig.isPaymobConfigured
                              ? 'بوابة الدفع مربوطة ✅'
                              : 'بوابة الدفع في وضع التجربة',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ApiConfig.isPaymobConfigured
                              ? 'الدفع بالبطاقة شغال وبيحوّل على حسابك'
                              : 'الفلوس مش بتتحوّل فعلياً لحد ما تربط '
                                  'حساب Paymob — الخطوات في ملف README',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            AppButton(
              label: 'حفظ البيانات',
              icon: Icons.save_outlined,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
