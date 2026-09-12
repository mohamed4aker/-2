import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/settings_provider.dart';

/// "تواصل معنا" — بيانات المحل اللي الأدمن كتبها في لوحة التحكم.
///
/// كل سطر العميل يقدر ينسخه بضغطة (نسخ للحافظة) — من غير ما نضيف
/// مكتبات خارجية للفتح المباشر، عشان الابلكيشن يفضل خفيف ومن غير
/// أذونات زيادة.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;

    final rows = <Widget>[];

    void add(IconData icon, String label, String value, {bool ltr = false}) {
      if (value.trim().isEmpty) return;
      rows.add(
        _ContactTile(
          icon: icon,
          label: label,
          value: value.trim(),
          ltr: ltr,
          onTap: () => _copy(context, label, value.trim()),
        ),
      );
    }

    add(Icons.phone_outlined, 'رقم التليفون', s.storePhone, ltr: true);
    add(Icons.chat_outlined, 'الواتساب', s.whatsapp, ltr: true);
    add(Icons.mail_outline, 'البريد الإلكتروني', s.storeEmail, ltr: true);
    add(Icons.location_on_outlined, 'العنوان', s.storeAddress);
    add(Icons.map_outlined, 'الموقع على الخريطة', s.mapsLink, ltr: true);
    add(Icons.access_time, 'مواعيد العمل', s.workingHours);
    add(Icons.facebook_outlined, 'فيسبوك', s.facebook, ltr: true);
    add(Icons.camera_alt_outlined, 'إنستجرام', s.instagram, ltr: true);
    add(Icons.music_note_outlined, 'تيك توك', s.tiktok, ltr: true);

    return Scaffold(
      appBar: AppBar(title: const Text('تواصل معنا')),
      body: rows.isEmpty && s.aboutStore.trim().isEmpty
          ? const EmptyView(
              icon: Icons.contact_phone_outlined,
              title: 'لسه مفيش بيانات تواصل',
              subtitle: 'هتظهر هنا أول ما المتجر يضيفها',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ---------- ترويسة المحل ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.storeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (s.aboutStore.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          s.aboutStore.trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (rows.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'وسائل التواصل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'دوس على أي سطر عشان تنسخه',
                    style: TextStyle(fontSize: 12, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 12),
                  ...rows,
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.ltr,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.grey),
        ),
        subtitle: Text(
          value,
          textDirection: ltr ? TextDirection.ltr : null,
          textAlign: ltr ? TextAlign.left : null,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.copy_outlined, size: 18),
      ),
    );
  }
}
