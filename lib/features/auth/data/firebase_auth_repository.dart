import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../core/config/app_config.dart';
import 'auth_repository.dart';
import 'models/app_user.dart';

/// المصادقة على سيرفر Firebase.
///
/// العميل بيسجّل برقم هاتفه — وعشان Firebase محتاج بريد إلكتروني،
/// بنحوّل الرقم لبريد داخلي بالشكل: `01012345678@moda.app`
/// (العميل مش بيشوف ده خالص، بيدخل برقمه عادي).
class FirebaseAuthRepository implements AuthRepository {
  final _auth = fb.FirebaseAuth.instance;
  final _users =
      FirebaseFirestore.instance.collection(AppConfig.collectionUsers);

  /// بيحوّل رقم الهاتف لبريد داخلي يقبله Firebase.
  String _emailFor(String identifier) {
    final clean = identifier.trim();
    if (clean.contains('@')) return clean;
    return '$clean@moda.app';
  }

  @override
  Future<AppUser> login(String identifier, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailFor(identifier),
        password: password,
      );
      return _loadProfile(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e));
    }
  }

  @override
  Future<AppUser> register(
    String name,
    String phone,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailFor(phone),
        password: password,
      );

      final user = AppUser(
        id: credential.user!.uid,
        name: name.trim(),
        phone: phone.trim(),
        email: null,
        password: '',
        role: UserRole.customer,
      );
      await _users.doc(user.id).set(user.toJson());
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e));
    }
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    // للتفعيل: ضيف حزمة google_sign_in واعمل:
    //   final googleUser = await GoogleSignIn().signIn();
    //   final googleAuth = await googleUser!.authentication;
    //   final credential = fb.GoogleAuthProvider.credential(
    //     accessToken: googleAuth.accessToken,
    //     idToken: googleAuth.idToken,
    //   );
    //   final result = await _auth.signInWithCredential(credential);
    //   return _loadProfile(result.user!);
    throw Exception(
      'تسجيل الدخول بجوجل محتاج تفعيل — راجع خطوات "حساب جوجل" في README',
    );
  }

  @override
  Future<AppUser> continueAsGuest() async {
    final credential = await _auth.signInAnonymously();
    return AppUser(
      id: credential.user!.uid,
      name: 'ضيف',
      phone: '',
      password: '',
      role: UserRole.customer,
      provider: AuthMethod.guest,
    );
  }

  /// بيقرأ بيانات المستخدم من Firestore، ولو مش موجودة بينشئها.
  Future<AppUser> _loadProfile(fb.User firebaseUser) async {
    final doc = await _users.doc(firebaseUser.uid).get();

    if (doc.exists) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = firebaseUser.uid;
      final user = AppUser.fromJson(data);
      // الأدمن بيتحدد ببريده في AppConfig.
      if (firebaseUser.email == AppConfig.adminEmail) {
        return AppUser(
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: firebaseUser.email,
          password: '',
          role: UserRole.admin,
          provider: user.provider,
        );
      }
      return user;
    }

    final isAdmin = firebaseUser.email == AppConfig.adminEmail;
    final user = AppUser(
      id: firebaseUser.uid,
      name: isAdmin ? 'صاحب المتجر' : (firebaseUser.displayName ?? 'عميل'),
      phone: firebaseUser.email?.split('@').first ?? '',
      email: firebaseUser.email,
      password: '',
      role: isAdmin ? UserRole.admin : UserRole.customer,
    );
    await _users.doc(user.id).set(user.toJson());
    return user;
  }

  /// رسائل خطأ بالعربي بدل رسائل Firebase الإنجليزية.
  String _messageFor(fb.FirebaseAuthException e) => switch (e.code) {
        'user-not-found' => 'الحساب ده مش موجود — اعمل حساب جديد',
        'wrong-password' || 'invalid-credential' =>
          'بيانات الدخول غير صحيحة، تأكد من الرقم وكلمة المرور',
        'email-already-in-use' =>
          'رقم الهاتف مسجل بالفعل، جرّب تسجيل الدخول',
        'weak-password' => 'كلمة المرور ضعيفة — 6 أحرف على الأقل',
        'network-request-failed' =>
          'مفيش اتصال بالإنترنت — تأكد من الشبكة',
        'too-many-requests' =>
          'محاولات كتير — استنى شوية وحاول تاني',
        _ => 'حصل خطأ: ${e.message ?? e.code}',
      };

  @override
  Future<void> logout() => _auth.signOut();
}
