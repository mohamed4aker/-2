import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../admin/screens/admin_shell.dart';
import '../../products/screens/customer_shell.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.popOnSuccess = false});

  /// عند true: نرجع للشاشة السابقة بعد نجاح الدخول (مثلاً أثناء إتمام الطلب).
  final bool popOnSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSuccess(AuthProvider auth) {
    if (auth.isAdmin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminShell()),
        (route) => false,
      );
    } else if (widget.popOnSuccess) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerShell()),
        (route) => false,
      );
    }
  }

  void _showError(AuthProvider auth) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? 'حدث خطأ، حاول مرة أخرى')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _identifierController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    success ? _onSuccess(auth) : _showError(auth);
  }

  Future<void> _google() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();
    if (!mounted) return;
    success ? _onSuccess(auth) : _showError(auth);
  }

  Future<void> _guest() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.continueAsGuest();
    if (!mounted) return;
    success ? _onSuccess(auth) : _showError(auth);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        settings.storeName,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'أهلاً بيك من جديد',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'رقم الهاتف أو البريد الإلكتروني',
                    controller: _identifierController,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'أدخل رقم الهاتف أو البريد الإلكتروني'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'كلمة المرور',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    obscure: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'كلمة المرور 6 أحرف على الأقل'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'تسجيل الدخول',
                    loading: auth.loading,
                    onPressed: _submit,
                  ),

                  if (settings.googleSignInEnabled) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'أو',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: auth.loading ? null : _google,
                      icon: const _GoogleMark(),
                      label: const Text('المتابعة بحساب جوجل'),
                    ),
                  ],

                  if (settings.guestCheckoutEnabled) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: auth.loading ? null : _guest,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('المتابعة كضيف (من غير تسجيل)'),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegisterScreen(
                                popOnSuccess: widget.popOnSuccess,
                              ),
                            ),
                          );
                        },
                        child: const Text('إنشاء حساب جديد'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// شعار جوجل مبسّط بالأبيض والأسود (عشان يفضل الثيم موحّد).
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.6),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
