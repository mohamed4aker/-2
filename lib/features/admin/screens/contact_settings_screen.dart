import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../settings/providers/settings_provider.dart';

/// بيانات التواصل بتاعت المحل — اللي بيملاها الأدمن وبتظهر للعميل
/// في آخر جزء من شاشة الحساب تحت "تواصل معنا".
class ContactSettingsScreen extends StatefulWidget {
  const ContactSettingsScreen({super.key});

  @override
  State<ContactSettingsScreen> createState() => _ContactSettingsScreenState();
}

class _ContactSettingsScreenState extends State<ContactSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phone;
  late final TextEditingController _whatsapp;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _mapsLink;
  late final TextEditingController _workingHours;
  late final TextEditingController _facebook;
  late final TextEditingController _instagram;
  late final TextEditingController _tiktok;
  late final TextEditingController _about;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _phone = TextEditingController(text: s.storePhone);
    _whatsapp = TextEditingController(text: s.whatsapp);
    _email = TextEditingController(text: s.storeEmail);
    _address = TextEditingController(text: s.storeAddress);
    _mapsLink = TextEditingController(text: s.mapsLink);
    _workingHours = TextEditingController(text: s.workingHours);
    _facebook = TextEditingController(text: s.facebook);
    _instagram = TextEditingController(text: s.instagram);
    _tiktok = TextEditingController(text: s.tiktok);
    _about = TextEditingController(text: s.aboutStore);
  }

  @override
  void dispose() {
    for (final c in [
      _phone,
      _whatsapp,
      _email,
      _address,
      _mapsLink,
      _workingHours,
      _facebook,
      _instagram,
      _tiktok,
      _about,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<SettingsProvider>();
    await provider.update(
      provider.settings.copyWith(
        storePhone: _phone.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        storeEmail: _email.text.trim(),
        storeAddress: _address.text.trim(),
        mapsLink: _mapsLink.text.trim(),
        workingHours: _workingHours.text.trim(),
        facebook: _facebook.text.trim(),
        instagram: _instagram.text.trim(),
        tiktok: _tiktok.text.trim(),
        aboutStore: _about.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ بيانات التواصل ✅')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات التواصل')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الحاجات اللي هتملاها هنا بتظهر للعميل في آخر شاشة '
                      '"حسابي" تحت "تواصل معنا". سيب أي خانة فاضية لو مش '
                      'عايزها تظهر.',
                      style: TextStyle(fontSize: 12, height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------- التليفونات ----------
            const _Header('التليفون والواتساب'),
            AppTextField(
              label: 'رقم التليفون',
              controller: _phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'رقم الواتساب',
              hint: '01012345678',
              controller: _whatsapp,
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'البريد الإلكتروني (اختياري)',
              controller: _email,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return null;
                return value.contains('@') ? null : 'بريد غير صحيح';
              },
            ),

            // ---------- المكان ----------
            const _Header('المكان والمواعيد'),
            AppTextField(
              label: 'عنوان المحل',
              controller: _address,
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'رابط الموقع على خرائط جوجل (اختياري)',
              controller: _mapsLink,
              icon: Icons.map_outlined,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'مواعيد العمل',
              controller: _workingHours,
              icon: Icons.access_time,
            ),

            // ---------- السوشيال ----------
            const _Header('صفحات السوشيال'),
            AppTextField(
              label: 'فيسبوك (الرابط أو اسم الصفحة)',
              controller: _facebook,
              icon: Icons.facebook_outlined,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'إنستجرام',
              controller: _instagram,
              icon: Icons.camera_alt_outlined,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'تيك توك',
              controller: _tiktok,
              icon: Icons.music_note_outlined,
              textDirection: TextDirection.ltr,
            ),

            // ---------- نبذة ----------
            const _Header('نبذة عن المحل'),
            AppTextField(
              label: 'اكتب كلمتين عن المحل (اختياري)',
              controller: _about,
              icon: Icons.storefront_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 24),
            AppButton(
              label: 'حفظ بيانات التواصل',
              icon: Icons.save_outlined,
              loading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
