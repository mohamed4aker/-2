import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../admin/screens/admin_shell.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../orders/screens/my_orders_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/screens/contact_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// شاشة الحساب: الطلبات، الإشعارات، المفضلة، وتسجيل الدخول/الخروج.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: auth.isLoggedIn ? _LoggedInView(auth: auth) : const _GuestView(),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_outline, size: 72, color: AppTheme.grey),
            const SizedBox(height: 16),
            const Text(
              'سجّل دخولك لمتابعة طلباتك وإتمام الشراء',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'تسجيل الدخول',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'إنشاء حساب جديد',
              outlined: true,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              ),
              icon: const Icon(Icons.support_agent_outlined, size: 18),
              label: const Text('تواصل معنا'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  const _LoggedInView({required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.user!;
    final settings = context.watch<SettingsProvider>().settings;
    final unread = context.watch<NotificationsProvider>().unreadCount;
    final favCount = context.watch<FavoritesProvider>().count;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  user.isGuest ? Icons.person_outline : Icons.person,
                  color: Colors.black,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.isGuest
                          ? 'حساب ضيف — الطلبات مش هتتحفظ'
                          : (user.email ?? user.phone),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (user.isGuest) ...[
          const SizedBox(height: 16),
          AppButton(
            label: 'اعمل حساب واحتفظ بطلباتك',
            outlined: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ),
        ],

        const SizedBox(height: 16),
        if (auth.isAdmin)
          _Tile(
            icon: Icons.dashboard_outlined,
            title: 'لوحة تحكم المتجر',
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AdminShell()),
              (route) => false,
            ),
          ),
        _Tile(
          icon: Icons.receipt_long_outlined,
          title: 'طلباتي',
          subtitle: 'تابع حالة طلباتك واطبع الإيصالات',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
          ),
        ),
        _Tile(
          icon: Icons.notifications_outlined,
          title: 'الإشعارات',
          subtitle: unread > 0 ? '$unread إشعار جديد' : 'مفيش جديد',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        _Tile(
          icon: Icons.favorite_border,
          title: 'المفضلة',
          subtitle: '$favCount منتج',
        ),
        const Divider(height: 32),
        _Tile(
          icon: Icons.local_shipping_outlined,
          title: 'الشحن لجميع محافظات مصر',
          subtitle:
              'شحن مجاني للطلبات فوق ${settings.freeShippingOver.toStringAsFixed(0)} ج.م',
        ),
        _Tile(
          icon: Icons.support_agent_outlined,
          title: 'تواصل معنا',
          subtitle: settings.hasContactInfo
              ? 'واتساب · تليفون · سوشيال · مواعيد العمل'
              : settings.storePhone,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ContactScreen()),
          ),
        ),
        _Tile(
          icon: Icons.storefront_outlined,
          title: settings.storeName,
          subtitle: settings.storeAddress,
        ),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('تسجيل الخروج'),
          onTap: () async {
            await context.read<AuthProvider>().logout();
          },
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 12)),
      trailing: onTap == null
          ? null
          : const Icon(Icons.arrow_back_ios_new, size: 14),
      onTap: onTap,
    );
  }
}
