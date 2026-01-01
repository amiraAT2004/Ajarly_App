import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/screens/tanent/bottomnavbar.dart';
import 'package:ajarly/screens/owner/owner_home_page.dart';
import 'package:ajarly/screens/auth/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ SplashScreen
/// شاشة البداية (تظهر ثواني قليلة) ثم تتحقق:
/// 1) هل المستخدم مسجل دخول؟
/// 2) لو مسجل: شنو دوره من Firestore (tenant / owner)؟
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// ✅ هذا المتغير يمنع تكرار التنقل مرتين
  /// (مهم لأن أحياناً _goNext قد تنادي _replace أكثر من مرة بسبب أخطاء/تأخير)
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    /// ✅ أول ما تفتح الشاشة نبدأ عملية التوجيه
    _goNext();
  }

  /// ✅ الدالة التي تحدد وين نمشي بعد السبلّاش
  Future<void> _goNext() async {
    /// ✅ نخلي السبلّاش ظاهر لمدة ثانيتين
    await Future.delayed(const Duration(seconds: 2));

    /// ✅ حماية: لو الصفحة اتقفلت قبل ما يخلص التأخير
    if (!mounted) return;

    /// ✅ نجيب المستخدم الحالي من FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    // ============================
    // ✅ الحالة 1: المستخدم مش مسجل
    // ============================
    if (user == null) {
      _replace(const WelcomeScreen());
      return;
    }

    // ==================================
    // ✅ الحالة 2: المستخدم مسجل دخول
    // نقرأ بياناته من Firestore لمعرفة role
    // ==================================
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      /// ✅ لو document مش موجود:
      /// معناها حساب قديم أو فشل حفظ البيانات وقت التسجيل
      if (!doc.exists) {
        _replace(const WelcomeScreen());
        return;
      }

      /// ✅ نجيب بيانات المستخدم
      final data = doc.data();

      /// ✅ role نخليه string وننظفه من المسافات
      final role = (data?['role'] ?? '').toString().trim();

      /// ✅ توجيه حسب الدور الحقيقي
      if (role == 'tenant') {
        _replace(Bottomnavigatorbar());
        return;
      }

      if (role == 'owner') {
        _replace(const OwnerHomePage());
        return;
      }

      /// ✅ لو الدور فاضي أو غير معروف
      _replace(const WelcomeScreen());
    } catch (e) {
      /// ✅ لو صار أي خطأ في قراءة Firestore (نت/صلاحيات/..)
      _replace(const WelcomeScreen());
    }
  }

  /// ✅ دالة تنقل مع استبدال الصفحة الحالية (Splash)
  void _replace(Widget page) {
    /// ✅ لو سبق وتوجهنا خلاص ما نعيدش التنقل
    if (_navigated) return;

    _navigated = true;

    /// pushReplacement: يقفل Splash ويحط الصفحة الجديدة مكانها
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ✅ خلفية ملونة تغطي الشاشة كاملة
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color.fromRGBO(26, 141, 153, 1)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ✅ TweenAnimationBuilder: حركة Fade + نزول بسيط للشعار
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeIn,
                builder: (_, value, child) {
                  /// value تمشي من 0 إلى 1
                  /// نستخدمها في:
                  /// - Opacity (الشفافية)
                  /// - Transform.translate (التحريك)
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 20), // نزول بسيط بالبداية
                      child: child,
                    ),
                  );
                },

                /// child: هذا هو الشعار نفسه (يتحرك/يظهر مع الأنيميشن)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logo.png',
                    height: AppDimensions.screenHeight * .30,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ✅ النص المتحرك (أسهل - أوفر - أسرع)
              const _HeadlineWithCurve(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Widget خاص بالنص المتحرك تحت الشعار
class _HeadlineWithCurve extends StatefulWidget {
  const _HeadlineWithCurve();

  @override
  State<_HeadlineWithCurve> createState() => _HeadlineWithCurveState();
}

class _HeadlineWithCurveState extends State<_HeadlineWithCurve>
    with TickerProviderStateMixin {
  /// ✅ AnimationController يتحكم في زمن الأنيميشن
  late final AnimationController _wordCtrl;

  @override
  void initState() {
    super.initState();

    /// ✅ مدة 1200ms ثم يبدأ مباشرة forward()
    _wordCtrl = AnimationController(
      vsync: this, // مهم لأن الصفحة فيها Animation
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    /// ✅ لازم نغلق الـ controller لتفادي memory leak
    _wordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ نمط الخط
    const txtStyle = TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    /// AnimatedBuilder: يعيد بناء الواجهة مع تغيّر قيمة animation
    return AnimatedBuilder(
      animation: _wordCtrl,
      builder: (_, __) {
        /// ✅ قيمة الأنيميشن من 0 إلى 1
        final v = _wordCtrl.value;

        /// ✅ نقسم الظهور إلى 3 مراحل:
        /// w1 تظهر "أسهل"
        /// w2 تظهر "أوفر"
        /// w3 تظهر "أسرع"
        /// بحيث يظهروا بالتتابع وليس مرة وحدة
        final w1 = (v.clamp(0.0, .33) * 3);
        final w2 = ((v - .33).clamp(0.0, .33) * 3);
        final w3 = ((v - .66).clamp(0.0, .34) * 2.94);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ آخر كلمة تظهر (أسرع)
            Opacity(opacity: w3, child: const Text('أسرع', style: txtStyle)),
            const SizedBox(width: 16),

            /// ✅ ثاني كلمة تظهر (أوفر)
            Opacity(opacity: w2, child: const Text('أوفر', style: txtStyle)),
            const SizedBox(width: 16),

            /// ✅ أول كلمة تظهر (أسهل)
            Opacity(opacity: w1, child: const Text('أسهل', style: txtStyle)),
          ],
        );
      },
    );
  }
}
