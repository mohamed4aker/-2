import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../admin/screens/admin_shell.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// شاشة الحساب: تسجيل دخول/خروج + دخول لوحة الأدمن.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: auth.isLoggedIn
          ? _LoggedInView(auth: auth)
          : const _GuestView(),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_outline, size: 72, color: AppTheme.grey),
            const SizedBox(height: 16),
            const Text(
              'سجلي الدخول لمتابعة طلباتك وإتمام الشراء',
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
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black, size: 32),
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
                      user.email ?? user.phone,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (auth.isAdmin)
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('لوحة تحكم المتجر'),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AdminShell()),
              (route) => false,
            ),
          ),
        const ListTile(
          leading: Icon(Icons.local_shipping_outlined),
          title: Text('الشحن لجميع محافظات مصر'),
          subtitle: Text('شحن مجاني للطلبات فوق 2000 ج.م'),
        ),
        const ListTile(
          leading: Icon(Icons.support_agent_outlined),
          title: Text('خدمة العملاء'),
          subtitle: Text('من 10 صباحاً حتى 10 مساءً'),
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
