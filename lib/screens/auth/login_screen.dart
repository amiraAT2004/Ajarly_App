import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/const/user_role.dart';
import 'package:ajarly/screens/owner/owner_home_page.dart';
import 'package:ajarly/screens/tanent/bottomnavbar.dart';
import 'package:ajarly/screens/auth/signUp_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ LoginScreen
/// صفحة تسجيل الدخول.
/// الفكرة العامة:
/// 1) المستخدم يكتب email + password.
/// 2) نسجل الدخول بـ FirebaseAuth.
/// 3) بعد تسجيل الدخول، نجيب Role متاعه من Firestore (users/{uid}).
/// 4) حسب الـ Role نفتح صفحة المستأجر أو صفحة المالك.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controllers باش نقرأ القيم اللي يكتبها المستخدم
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();

  /// متغير باش نخفي/نظهر كلمة المرور
  bool _obscurePassword = true;

  /// FormKey للتحقق من صحة الفورم قبل الإرسال
  final _formKey = GlobalKey<FormState>();

  /// Loading state (باش نعرض CircularProgressIndicator)
  bool isLoading = false;

  @override
  void dispose() {
    /// ✅ مهم: لازم نفك الـ controllers من الذاكرة
    emailAddress.dispose();
    password.dispose();
    super.dispose();
  }

  /// ✅ يحدد الصفحة اللي نمشيلها بعد الدخول حسب الدور
  /// tenant -> Bottomnavigatorbar
  /// owner  -> OwnerHomePage
  Widget _homeByRole(UserRole role) {
    return role == UserRole.tenant
        ? const Bottomnavigatorbar()
        : const OwnerHomePage();
  }

  /// ✅ قراءة الدور من Firestore
  /// نخزن role داخل users/{uid} وقت التسجيل
  /// هنا وقت تسجيل الدخول نحتاج نعرف هل هو tenant ولا owner
  Future<UserRole?> _getUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    /// لو مفيش document أصلاً للمستخدم
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;

    /// roleFromString() دالة عندك ترجع enum UserRole من قيمة نصية
    /// مثال: "tenant" -> UserRole.tenant
    return roleFromString(data['role']?.toString());
  }

  /// ✅ لو المستخدم قديم وما عنده role مخزن (مثلاً قبل ما تضيف role)
  /// نخليه يختار دوره مرة واحدة
  Future<UserRole?> _askRoleIfMissing() async {
    return showDialog<UserRole>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("اختر نوع الحساب"),
        content: const Text(
          "حسابك لا يحتوي على نوع (Role) في قاعدة البيانات.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, UserRole.tenant),
            child: const Text("مستأجر"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, UserRole.owner),
            child: const Text("مالك / وكيل"),
          ),
        ],
      ),
    );
  }

  /// ✅ حفظ role في Firestore لو كان ناقص
  /// SetOptions(merge: true) معناها: "حدّث هذا الحقل فقط وما تمسحش باقي الحقول"
  Future<void> _saveRoleIfMissing(String uid, UserRole role) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "role": roleToString(role),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ عملية تسجيل الدخول
  Future<void> _login() async {
    /// 1) نتحقق من الفورم
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 2) تسجيل الدخول عبر FirebaseAuth
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.text.trim(),
        password: password.text.trim(),
      );

      /// 3) نجيب uid للمستخدم المسجل
      final uid = cred.user?.uid;
      if (uid == null) throw Exception("UID is null");

      /// 4) نقرأ الدور الحقيقي من Firestore
      UserRole? role = await _getUserRole(uid);

      /// 5) لو الدور ناقص (حساب قديم)
      /// نخليه يختار الدور ثم نخزنه
      if (role == null) {
        role = await _askRoleIfMissing();
        if (role == null) {
          /// المستخدم سكّر الديالوج بدون اختيار
          setState(() => isLoading = false);
          return;
        }
        await _saveRoleIfMissing(uid, role);
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      /// 6) ننتقل للواجهة المناسبة ونمنع الرجوع للـ Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _homeByRole(role!)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      /// ✅ أخطاء FirebaseAuth المشهورة
      if (!mounted) return;
      setState(() => isLoading = false);

      String title = 'خطأ';
      String message = 'حدث خطأ أثناء تسجيل الدخول';

      /// user-not-found: البريد غير موجود
      if (e.code == 'user-not-found') {
        title = 'المستخدم غير موجود';
        message = 'يرجى التحقق من البريد الإلكتروني وكلمة المرور';
      }
      /// wrong-password: كلمة مرور خطأ
      else if (e.code == 'wrong-password') {
        title = 'كلمة المرور خاطئة';
        message = 'يرجى التحقق من البريد الإلكتروني وكلمة المرور';
      }

      /// ✅ عرض رسالة بطريقة جميلة عبر AwesomeDialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: title,
        desc: message,
      ).show();
    } catch (e) {
      /// ✅ أي خطأ عام آخر
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// ✅ AppBar
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'تسجيل الدخول',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        /// ✅ لو loading = true نعرض مؤشر تحميل
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    /// ✅ صورة/لوجو أعلى الصفحة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/logo.png',
                        height: AppDimensions.screenHeight * .35,
                      ),
                    ),

                    /// ✅ Form
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            /// ✅ Email field
                            TextFormField(
                              controller: emailAddress,
                              decoration: InputDecoration(
                                hintText: 'البريد الإلكتروني',
                                label: const Text("البريد الإلكتروني"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: primary,
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: primary,
                                ),
                              ),
                              cursorColor: primary,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'الرجاء إدخال البريد الإلكتروني'
                                  : null,
                            ),

                            const SizedBox(height: 20),

                            /// ✅ Password field
                            TextFormField(
                              controller: password,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'كلمة المرور',
                                label: const Text("كلمة المرور"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: primary,
                                  ),
                                ),

                                /// زر إظهار/إخفاء كلمة المرور
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: primary,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: primary,
                                ),
                              ),
                              cursorColor: primary,
                              validator: (v) => (v == null || v.length < 6)
                                  ? '6 أحرف على الأقل'
                                  : null,
                            ),

                            const SizedBox(height: 20),

                            /// ✅ زر تسجيل الدخول
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// ✅ رابط التسجيل
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("ليس لديك حساب؟"),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'سجل الآن',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}