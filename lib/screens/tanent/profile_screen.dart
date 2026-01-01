import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/screens/info_app.dart';
import 'package:ajarly/screens/policy_screen.dart';
import 'package:ajarly/screens/terms_screen.dart';
import 'package:ajarly/screens/auth/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ صفحة الملف الشخصي (Profile)
/// تحتوي على:
/// 1) معلومات/ترحيب بالمستخدم
/// 2) روابط صفحات: الشروط، الخصوصية، عن التطبيق
/// 3) زر تسجيل الخروج (Logout)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Scaffold = هيكل الصفحة الأساسي (AppBar + Body)
    return Scaffold(
      // ======================
      // ✅ شريط علوي (AppBar)
      // ======================
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(color: Colors.white),
        ),
        // لون أيقونة الرجوع وغيره
        iconTheme: const IconThemeData(color: Colors.white),
        // لون الـ AppBar
        backgroundColor: const Color.fromRGBO(26, 141, 153, 1),
      ),

      // ======================
      // ✅ محتوى الصفحة (Body)
      // ======================
      body: Column(
        children: [
          // ======================
          // ✅ جزء الترحيب بالأعلى
          // ======================
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              // صورة دائرية (Avatar)
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/manager.png'),
              ),

              // عنوان الترحيب
              title: const Text(
                'مرحباً زبوننا العزيز',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              // ملاحظة: تقدر تضيف subtitle هنا إذا تبي تعرض اسم المستخدم مثلاً
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // خط فاصل (Divider) لتحسين شكل القائمة
          const Divider(
            thickness: 1,
            color: Colors.grey,
            height: 1,
            indent: 30,
            endIndent: 30,
          ),

          // ======================
          // ✅ قائمة: الأحكام والشروط
          // ======================
          ListTile(
            leading: const Icon(
              Icons.policy,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('الأحكام و الشروط'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// عند الضغط: يفتح صفحة الشروط
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TermsConditionsScreen()),
              );
            },
          ),

          // ======================
          // ✅ قائمة: تقييم التطبيق
          // ======================
          ListTile(
            leading: const Icon(
              Icons.rate_review,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('تقييم التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// حالياً فاضي
            /// ملاحظة للطلاب: هنا تقدر تربطه بـ Google Play / App Store
            onTap: () {},
          ),

          // ======================
          // ✅ قائمة: سياسة الخصوصية
          // ======================
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// عند الضغط: يفتح صفحة سياسة الخصوصية
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
              );
            },
          ),

          // ======================
          // ✅ قائمة: عن التطبيق
          // ======================
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('عن التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// عند الضغط: يفتح صفحة معلومات عن التطبيق
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InfoApp()),
              );
            },
          ),

          // Divider ثاني قبل قسم Logout
          const Divider(
            thickness: 1,
            color: Colors.grey,
            height: 1,
            indent: 25,
            endIndent: 30,
          ),

          const SizedBox(height: 10),

          // ======================
          // ✅ تسجيل الخروج
          // ======================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),

            /// عند الضغط:
            /// 1) نسوي signOut من FirebaseAuth
            /// 2) نرجع لصفحة WelcomeScreen
            /// 3) ونمسح كل الصفحات السابقة من الـ stack (باش ما يقدرش يرجع بزر الرجوع)
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
