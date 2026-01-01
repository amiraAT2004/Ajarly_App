import 'package:ajarly/screens/owner/owner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'owner_properties_screen.dart';
import 'owner_requests_screen.dart';

/// ✅ OwnerHomePage
/// هذه الصفحة هي "الرئيسية" للمالك/الوكيل
/// وفيها BottomNavigationBar للتنقل بين:
/// 1) عقاراتي
/// 2) الطلبات
/// 3) الملف الشخصي
class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  /// ✅ index: رقم التبويب الحالي المختار في الـ BottomNavigationBar
  /// 0 = عقاراتي
  /// 1 = الطلبات
  /// 2 = الملف الشخصي
  int index = 0;

  /// ✅ قائمة الصفحات اللي سيتم عرضها حسب قيمة index
  /// ملاحظة: ترتيبها مهم جداً لازم يطابق ترتيب عناصر BottomNavigationBar
  final pages = const [
    OwnerPropertiesScreen(), // 0
    OwnerRequestsScreen(), // 1
    OwnerProfileScreen(), // 2
  ];

  @override
  Widget build(BuildContext context) {
    /// ✅ لون التطبيق الأساسي
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Directionality(
      /// ✅ لأن التطبيق عربي (RTL)
      textDirection: TextDirection.rtl,
      child: Scaffold(
        /// ✅ body: يعرض الصفحة الحالية حسب index
        /// مثال: إذا index=1 -> يعرض OwnerRequestsScreen()
        body: pages[index],

        /// ✅ شريط التنقل السفلي
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,

          /// ✅ يحدد أي عنصر حاليًا مختار
          currentIndex: index,

          /// ✅ عند الضغط على أي تبويب يتم تغيير index
          /// setState مهم جداً لأنه يخلي الواجهة تعيد البناء وتعرض الصفحة الجديدة
          onTap: (i) => setState(() => index = i),

          /// ✅ لون العنصر المختار
          selectedItemColor: primary,

          /// ✅ عناصر BottomNavigationBar (ثلاث تبويبات)
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work_outlined),
              label: "عقاراتي",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              label: "الطلبات",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "الملف الشخصي",
            ),
          ],
        ),
      ),
    );
  }
}
