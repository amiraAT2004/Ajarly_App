import 'package:flutter/material.dart';

/// ✅ InfoApp
/// شاشة "عن التطبيق" تعرض:
/// - شعار التطبيق
/// - عنوان تعريفي
/// - وصف عام للتطبيق
/// - قائمة مميزات (Features)
/// - رقم الإصدار
class InfoApp extends StatelessWidget {
  const InfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// ✅ Directionality
    /// لأن التطبيق عربي، نخلي اتجاه النص من اليمين لليسار (RTL)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        /// ✅ AppBar (الشريط العلوي)
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(26, 141, 153, 1),
          elevation: 0, // بدون ظل تحت الـ AppBar
          centerTitle: true,
          title: const Text(
            'عن التطبيق',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white), // لون زر الرجوع
        ),

        /// ✅ Body
        /// SafeArea: يحمي المحتوى من النوتش/البار العلوي في الأجهزة
        body: SafeArea(
          /// ✅ SingleChildScrollView
          /// يخلي الصفحة قابلة للتمرير (مهم لو الشاشة صغيرة)
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =========================
                // ✅ 1) Logo (الشعار)
                // =========================
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 160, // حجم الشعار
                  ),
                ),
                const SizedBox(height: 25),

                // =========================
                // ✅ 2) Title (عنوان تعريفي)
                // =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة بسيطة بجانب العنوان
                    const Icon(
                      Icons.home_work_outlined,
                      color: Color.fromRGBO(26, 141, 153, 1),
                      size: 22,
                    ),
                    const SizedBox(width: 10),

                    /// Expanded: يخلي النص يتمدد ويكسر سطر لو النص طويل
                    Expanded(
                      child: Text(
                        'تطبيق أجرلي - أسهل طريقة للبحث عن عقار والتواصل مع المالك/الوكيل',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // =========================
                // ✅ 3) Description (وصف التطبيق)
                // =========================
                Text(
                  'أجرلي هو تطبيق يربط المستأجرين بمالكي العقارات والوكلاء العقاريين داخل ليبيا. '
                  'يمكن للمستأجر تصفح العروض، حفظ المفضلة، والتواصل لطلب موعد معاينة. '
                  'كما يمكن للمالك/الوكيل إضافة عقاراته مع الخدمات والصور وإدارة الطلبات بسهولة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    height: 1.6, // تباعد أسطر مريح للقراءة
                  ),
                ),
                const SizedBox(height: 25),

                // =========================
                // ✅ 4) Features (مميزات)
                // نستعمل دالة _buildFeatureItem لتفادي تكرار الكود
                // =========================
                _buildFeatureItem(
                  Icons.search,
                  'تصفح العروض والبحث حسب المدينة والسعر',
                ),
                const SizedBox(height: 12),

                _buildFeatureItem(
                  Icons.favorite,
                  'إضافة العقارات إلى المفضلة للرجوع لها لاحقًا',
                ),
                const SizedBox(height: 12),

                _buildFeatureItem(
                  Icons.apartment_outlined,
                  'إضافة عقار (اسم/مدينة/سعر/وصف/خدمات/صور)',
                ),
                const SizedBox(height: 12),

                _buildFeatureItem(
                  Icons.schedule,
                  'طلبات تواصل/زيارة: متابعة الطلبات وقبول/رفض أو رد برسالة',
                ),

                const SizedBox(height: 30),

                // =========================
                // ✅ 5) Version Tag (الإصدار)
                // =========================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // لون فاتح من نفس primary
                    color: const Color.fromRGBO(
                      26,
                      141,
                      153,
                      1,
                    ).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'الإصدار: V 1.0.0',
                    style: TextStyle(
                      color: Color.fromRGBO(26, 141, 153, 1),
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

  /// ✅ دالة تساعدنا نبني عنصر ميزة بشكل موحّد
  /// تستقبل:
  /// - icon: الأيقونة
  /// - text: نص الميزة
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        /// ✅ دائرة صغيرة خلف الأيقونة (ستايل جميل)
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(26, 141, 153, 1).withValues(alpha: .15),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: const Color.fromRGBO(26, 141, 153, 1),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        /// ✅ Expanded: يخلي النص ياخذ المساحة الباقية
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
