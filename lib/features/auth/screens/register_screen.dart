import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../products/screens/customer_shell.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.popOnSuccess = false});

  final bool popOnSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text,
      _phoneController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'حدث خطأ، حاول مرة أخرى')),
      );
      return;
    }

    if (widget.popOnSuccess) {
      // نرجع لشاشة الدفع: نقفل شاشة التسجيل وشاشة الدخول.
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'سجلي بياناتك وابدئي التسوق',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'الاسم',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'أدخلي الاسم'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.length < 10) {
                        return 'أدخلي رقم هاتف صحيح';
                      }
                      return null;
                    },
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
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'تأكيد كلمة المرور',
                    controller: _confirmController,
                    icon: Icons.lock_outline,
                    obscure: true,
                    validator: (v) => v != _passwordController.text
                        ? 'كلمتا المرور غير متطابقتين'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'إنشاء الحساب',
                    loading: loading,
                    onPressed: _submit,
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
