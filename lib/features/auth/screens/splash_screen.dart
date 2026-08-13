import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/screens/admin_shell.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../products/providers/products_provider.dart';
import '../../products/providers/reviews_provider.dart';
import '../../products/screens/customer_shell.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final products = context.read<ProductsProvider>();
    final settings = context.read<SettingsProvider>();
    final notifications = context.read<NotificationsProvider>();
    final favorites = context.read<FavoritesProvider>();
    final reviews = context.read<ReviewsProvider>();

    await Future.wait([
      auth.tryAutoLogin(),
      products.load(),
      settings.load(),
      notifications.load(),
      favorites.load(),
      reviews.load(),
      Future.delayed(const Duration(milliseconds: 1400)),
    ]);

    // فحص المنتجات الجديدة وغياب العميل بعد تحميل البيانات.
    if (!auth.isAdmin) {
      await notifications.runAutoChecks(
        products: products.products,
        settings: settings.settings,
      );
    }

    if (!mounted) return;
    final next = auth.isAdmin ? const AdminShell() : const CustomerShell();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'Moda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أزياء نسائية · أحذية · شنط · نظارات · إكسسوارات',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
