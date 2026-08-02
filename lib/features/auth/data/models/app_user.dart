/// أدوار المستخدم داخل التطبيق.
enum UserRole { admin, customer }

/// طريقة إنشاء الحساب.
enum AuthMethod { password, google, guest }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.password,
    required this.role,
    this.provider = AuthMethod.password,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;

  /// كلمة المرور مخزنة هنا فقط لأن هذا Mock — في الباك اند الحقيقي
  /// لا تُخزن كلمة المرور في التطبيق أبداً.
  final String password;
  final UserRole role;
  final AuthMethod provider;
  final String? photoUrl;

  bool get isAdmin => role == UserRole.admin;
  bool get isGuest => provider == AuthMethod.guest;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
        password: json['password'] as String? ?? '',
        role: json['role'] == 'admin' ? UserRole.admin : UserRole.customer,
        provider: AuthMethod.values.firstWhere(
          (p) => p.name == json['provider'],
          orElse: () => AuthMethod.password,
        ),
        photoUrl: json['photoUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role == UserRole.admin ? 'admin' : 'customer',
        'provider': provider.name,
        'photoUrl': photoUrl,
      };
}
