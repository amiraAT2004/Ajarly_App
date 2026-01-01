import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/screens/info_app.dart';
import 'package:ajarly/screens/policy_screen.dart';
import 'package:ajarly/screens/terms_screen.dart';
import 'package:ajarly/screens/auth/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ OwnerProfileScreen
/// صفحة الملف الشخصي الخاصة بالمالك/الوكيل.
/// تحتوي على:
/// - عنوان الصفحة
/// - معلومات بسيطة في الأعلى (صورة + ترحيب)
/// - عناصر قائمة (الأحكام، التقييم، الخصوصية، عن التطبيق)
/// - زر تسجيل الخروج
class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _ProfileScreenState();
}

/// State الخاصة بالصفحة
class _ProfileScreenState extends State<OwnerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ✅ خلفية الصفحة
      backgroundColor: Colors.white,

      /// ✅ AppBar (شريط علوي)
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(color: Colors.white),
        ),

        /// ✅ لون أيقونة الرجوع
        iconTheme: const IconThemeData(color: Colors.white),

        /// ✅ لون الـ AppBar الأساسي
        backgroundColor: const Color.fromRGBO(26, 141, 153, 1),
      ),

      /// ✅ محتوى الصفحة
      body: Column(
        children: [
          /// ✅ الجزء العلوي: صورة + ترحيب
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              /// صورة افتراضية (Avatar)
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/manager.png'),
              ),

              /// نص الترحيب
              title: const Text(
                'مرحباً زبوننا العزيز',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          /// ✅ مسافة صغيرة
          const SizedBox(height: AppDimensions.paddingMedium),

          /// ✅ خط فاصل
          Divider(
            thickness: 1,
            color: Colors.grey,
            height: 1,
            indent: 30,
            endIndent: 30,
          ),

          /// ✅ عنصر قائمة: الأحكام والشروط
          ListTile(
            leading: const Icon(
              Icons.policy,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('الأحكام و الشروط'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// ✅ عند الضغط: يفتح صفحة الأحكام والشروط
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TermsConditionsScreen()),
              );
            },
          ),

          /// ✅ عنصر قائمة: تقييم التطبيق
          ListTile(
            leading: const Icon(
              Icons.rate_review,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('تقييم التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// ✅ حاليا ما فيش كود (فارغة)
            /// لاحقاً ممكن نفتح رابط المتجر أو Dialog للتقييم
            onTap: () {},
          ),

          /// ✅ عنصر قائمة: سياسة الخصوصية
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// ✅ عند الضغط: يفتح صفحة سياسة الخصوصية
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
              );
            },
          ),

          /// ✅ عنصر قائمة: عن التطبيق
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Color.fromRGBO(26, 141, 153, 1),
            ),
            title: const Text('عن التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios),

            /// ✅ عند الضغط: يفتح صفحة "عن التطبيق"
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InfoApp()),
              );
            },
          ),

          /// ✅ خط فاصل قبل تسجيل الخروج
          Divider(
            thickness: 1,
            color: Colors.grey,
            height: 1,
            indent: 25,
            endIndent: 30,
          ),

          const SizedBox(height: 10),

          /// ✅ زر تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),

            /// ✅ عند الضغط:
            /// 1) تسجيل خروج من FirebaseAuth
            /// 2) فتح WelcomeScreen
            /// 3) إزالة كل الصفحات السابقة (pushAndRemoveUntil)
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomeScreen()),
                (route) => false, // ✅ يمسح الستاك بالكامل
              );
            },
          ),
        ],
      ),
    );
  }
}
