import 'package:ajarly/screens/tanent/favorite_screen.dart';
import 'package:ajarly/screens/tanent/home_screen.dart';
import 'package:ajarly/screens/tanent/profile_screen.dart';
import 'package:flutter/material.dart';

/// ✅ هذه صفحة الـ Bottom Navigation الخاصة بالمستأجر
/// الفكرة:
/// - عندنا 3 صفحات (الرئيسية / المفضلة / الملف الشخصي)
/// - المتغير index يحدد أي صفحة نعرضها
/// - عند الضغط على أيقونة من BottomNavigationBar نغير index
class Bottomnavigatorbar extends StatefulWidget {
  const Bottomnavigatorbar({super.key});

  @override
  State<Bottomnavigatorbar> createState() => _NavbarState();
}

class _NavbarState extends State<Bottomnavigatorbar> {
  /// ✅ رقم التبويب الحالي (0 = الرئيسية, 1 = المفضلة, 2 = الملف الشخصي)
  int index = 0;

  /// ✅ هذه الدالة تتنفذ لما المستخدم يضغط على أي تبويب
  /// نغيّر index ونعمل setState باش الواجهة تعاود تبني وتعرض الصفحة الجديدة
  void changeIndex(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// اللون الأساسي للتطبيق
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ دعم اتجاه عربي RTL
      child: Scaffold(
        /// ✅ body يبدّل الصفحة حسب قيمة index
        /// نستخدم List of Widgets:
        /// [0] HomeScreen
        /// [1] FavoritesScreen
        /// [2] ProfileScreen
        /// ونختار منهم العنصر اللي رقمه = index
        body:
            <Widget>[
              // 0 ✅ صفحة الرئيسية
              HomeScreen(),

              // 1 ✅ صفحة المفضلة
              FavoritesScreen(),

              // 2 ✅ صفحة الملف الشخصي
              ProfileScreen(),
            ][index],

        /// ✅ شريط التنقل السفلي
        bottomNavigationBar: BottomNavigationBar(
          onTap: changeIndex, // ✅ لما يضغط المستخدم نغير التبويب
          currentIndex: index, // ✅ التبويب الحالي (عشان يبين محدد)
          selectedItemColor: primary, // ✅ لون الأيقونة المختارة
          unselectedItemColor: Colors.grey[500], // ✅ لون غير المختارة
          /// ✅ عناصر الشريط (Tabs)
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'الملف الشخصي',
            ),
          ],
        ),
      ),
    );
  }
}
