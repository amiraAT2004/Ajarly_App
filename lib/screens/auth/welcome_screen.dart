import 'package:ajarly/const/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:ajarly/screens/auth/login_screen.dart';
import 'package:ajarly/screens/auth/signUp_screen.dart';

/// ✅ WelcomeScreen
/// هذه أول صفحة تظهر للمستخدم عند فتح التطبيق.
/// الهدف منها:
/// - تعريف بسيط بالتطبيق (اسم + أيقونة + شعار).
/// - إعطاء خيارين: تسجيل الدخول أو إنشاء حساب.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// اللون الأساسي المستخدم في الواجهة
    const primary = Color.fromRGBO(26, 141, 153, 1);

    /// Directionality: لأن التطبيق عربي، نخلي اتجاه النص RTL
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// SafeArea: يمنع المحتوى من الدخول تحت الـ Notch أو Status Bar
        body: SafeArea(
          child: Padding(
            /// padding أفقي ثابت من AppDimensions
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                /// ✅ الهيدر: أيقونة + اسم التطبيق
                Row(
                  children: [
                    /// مربع الأيقونة
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        /// خلفية خفيفة من اللون الأساسي
                        color: primary.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(16),

                        /// إطار بسيط
                        border: Border.all(
                          color: primary.withValues(alpha: .18),
                        ),
                      ),
                      child: const Icon(
                        Icons.home_work_outlined,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Expanded: يخلي النص يتمدد ويمنع overflow
                    const Expanded(
                      child: Text(
                        "أجرلي",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// ✅ وصف بسيط تحت الاسم
                Text(
                  "سجّل دخولك أو أنشئ حساب جديد",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// Spacer: يدفع العناصر لأسفل/أعلى حسب الحاجة
                const Spacer(),

                /// ✅ شعار/صورة التطبيق
                /// لازم تتأكد الصورة موجودة في assets ومضافة في pubspec.yaml
                Image.asset("assets/logo.png"),

                const Spacer(),

                /// ✅ زر تسجيل الدخول (ممتلئ بلون primary)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      /// ملاحظة: هنا استعملت OutlinedButton لكن خليته بشكل زر ممتلئ
                      foregroundColor: primary,
                      backgroundColor: primary,
                      side: BorderSide(color: primary.withValues(alpha: .55)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    /// عند الضغط: نفتح صفحة LoginScreen
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },

                    child: const Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ✅ زر إنشاء حساب (خلفية بيضاء + إطار)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    /// ملاحظة: هنا استعملت ElevatedButton لكن الـ style من OutlinedButton
                    /// الأفضل (للنظافة) تستخدم ElevatedButton.styleFrom بدل OutlinedButton.styleFrom
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    /// عند الضغط: نفتح صفحة SignupScreen
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },

                    child: const Text(
                      "إنشاء حساب",
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
