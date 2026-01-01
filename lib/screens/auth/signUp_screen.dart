import 'dart:async';
import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/const/user_role.dart';
import 'package:ajarly/screens/tanent/bottomnavbar.dart';
import 'package:ajarly/screens/owner/owner_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ✅ SignupScreen
/// صفحة إنشاء حساب جديد.
/// تسلسل العمل:
/// 1) المستخدم يعبّي الفورم (اسم/إيميل/هاتف/باسورد + نوع الحساب).
/// 2) ننشئ حساب في FirebaseAuth بالإيميل والباسورد.
/// 3) نخزن بيانات إضافية في Firestore داخل users/{uid}.
/// 4) نمشي للواجهة المناسبة حسب Role (مستأجر/مالك).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /// مفتاح الفورم: نستخدمه باش نعمل validate قبل التسجيل
  final _formKey = GlobalKey<FormState>();

  /// Controllers باش نقرأ بيانات الحقول
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  /// لإظهار/إخفاء كلمة المرور
  bool _obscurePassword = true;

  /// حالة تحميل (باش نعرض loading أثناء التسجيل)
  bool isLoading = false;

  /// ✅ الدور يختاره المستخدم (افتراضي: مستأجر)
  UserRole selectedRole = UserRole.tenant;

  @override
  void dispose() {
    /// ✅ مهم: نتأكد نفك الـ controllers من الذاكرة
    _emailController.dispose();
    _passController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// ✅ يحدد الصفحة اللي نمشيلها بعد التسجيل حسب الدور
  Widget _homeByRole(UserRole role) {
    return role == UserRole.tenant
        ? const Bottomnavigatorbar()
        : const OwnerHomePage();
  }

  /// ✅ الوظيفة الأساسية للتسجيل
  Future<void> _registerUser() async {
    /// 1) نتحقق من الفورم
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 2) إنشاء مستخدم داخل FirebaseAuth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      /// 3) نتأكد إن اليوزر فعلاً اتسجل
      final user = credential.user;
      if (user == null) throw Exception("User is null after signup");

      /// 4) تخزين بيانات إضافية في Firestore
      /// users/{uid} => document خاص بالمستخدم
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'firstName': _firstName.text.trim(),
            'lastName': _lastName.text.trim(),
            'email': _emailController.text.trim(),
            'role': roleToString(selectedRole), // تحويل enum إلى String
            'phone': _phone.text.trim(), // الهاتف (بعد validation)
            'createdAt': FieldValue.serverTimestamp(),
          })
          /// timeout: لو صار بطء أو تعليق في النت، نوقف بعد 8 ثواني
          .timeout(const Duration(seconds: 8));

      /// 5) بعد نجاح التسجيل: نوقف التحميل ونمشي للصفحة المناسبة
      if (!mounted) return;
      setState(() => isLoading = false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _homeByRole(selectedRole)),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      /// ✅ أخطاء FirebaseAuth المعروفة
      if (!mounted) return;
      setState(() => isLoading = false);

      String message;

      if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جدًا';
      } else if (e.code == 'email-already-in-use') {
        message = 'البريد مستخدم مسبقًا';
      } else {
        message = 'حدث خطأ: ${e.message}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      /// ✅ أخطاء عامة (Firestore/Network/Timeout...)
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ غير متوقع: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'إنشاء حساب',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primary,
          centerTitle: true,
        ),

        /// ✅ Form يحط كل الحقول تحت validate
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                /// ✅ اختيار نوع الحساب
                const Text(
                  "نوع الحساب",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _RolePickCard(
                        title: "مستأجر",
                        selected: selectedRole == UserRole.tenant,
                        onTap:
                            () => setState(() {
                              selectedRole = UserRole.tenant;
                            }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RolePickCard(
                        title: "مالك / وكيل",
                        selected: selectedRole == UserRole.owner,
                        onTap:
                            () => setState(() {
                              selectedRole = UserRole.owner;
                            }),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ✅ الاسم الأول
                TextFormField(
                  controller: _firstName,
                  decoration: InputDecoration(
                    hintText: 'الاسم الأول',
                    label: const Text("الاسم الأول"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 2, color: primary),
                    ),
                    prefixIcon: const Icon(Icons.person, color: primary),
                  ),
                  cursorColor: primary,
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'الرجاء إدخال الاسم الأول'
                              : null,
                ),

                const SizedBox(height: 15),

                /// ✅ اسم العائلة
                TextFormField(
                  controller: _lastName,
                  decoration: InputDecoration(
                    hintText: 'اسم العائلة',
                    label: const Text("اسم العائلة"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 2, color: primary),
                    ),
                    prefixIcon: const Icon(Icons.person, color: primary),
                  ),
                  cursorColor: primary,
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'الرجاء إدخال اسم العائلة'
                              : null,
                ),

                const SizedBox(height: 15),

                /// ✅ البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني',
                    label: const Text("البريد الإلكتروني"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 2, color: primary),
                    ),
                    prefixIcon: const Icon(Icons.email, color: primary),
                  ),
                  cursorColor: primary,
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'الرجاء إدخال البريد الإلكتروني'
                              : null,
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                /// ✅ رقم الهاتف
                /// - keyboardType: يخلي الكيبورد يفتح أرقام/هاتف
                /// - inputFormatters:
                ///   1) digitsOnly => يمنع الحروف والرموز
                ///   2) LengthLimiting => يمنع أكثر من 10 أرقام
                /// - validator:
                ///   1) لازم مش فاضي
                ///   2) لازم 10 أرقام
                ///   3) لازم يبدأ بـ 091 أو 092 أو 093 أو 094
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: 'مثال: 0912345678',
                    label: const Text("رقم الهاتف"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 2, color: primary),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: primary),
                  ),
                  cursorColor: primary,
                  validator: (v) {
                    final raw = (v ?? '').trim();

                    if (raw.isEmpty) return 'الرجاء إدخال رقم الهاتف';

                    /// نخلي الرقم "نظيف" لو المستخدم لصق رقم فيه مسافات
                    final phone = raw.replaceAll(RegExp(r'[^0-9]'), '');

                    if (phone.length != 10)
                      return 'رقم الهاتف لازم يكون 10 أرقام';

                    /// Regex: يبدأ بـ 091/092/093/094 وبعدها 7 أرقام
                    if (!RegExp(r'^(091|092|093|094)\d{7}$').hasMatch(phone)) {
                      return 'لازم يبدأ بـ 091 أو 092 أو 093 أو 094';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                /// ✅ كلمة المرور
                TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    label: const Text("كلمة المرور"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 2, color: primary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primary,
                      ),
                      onPressed:
                          () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: primary),
                  ),
                  cursorColor: primary,
                  validator:
                      (v) =>
                          (v == null || v.length < 6)
                              ? '6 أحرف على الأقل'
                              : null,
                ),

                const SizedBox(height: 25),

                /// ✅ زر التسجيل أو loading
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      onPressed: _registerUser,
                      child: const Text(
                        'تسجيل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ كرت اختيار الدور (Role)
/// مجرد UI بسيط: يتغير لونه حسب هل هو Selected ولا لا
class _RolePickCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RolePickCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: .10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected
                    ? primary.withValues(alpha: .55)
                    : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? primary : Colors.black87,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
