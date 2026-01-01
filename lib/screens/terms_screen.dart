import 'package:flutter/material.dart';

/// ✅ TermsConditionsScreen
/// شاشة "الأحكام والشروط"
/// الهدف منها:
/// - عرض شروط استخدام التطبيق للمستخدم
/// - تكون قابلة للتمرير لأن النص طويل
/// - تقسيم المحتوى لأقسام: (عنوان + نص)
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// ✅ Directionality
    /// لأن اللغة عربية: نخلي اتجاه الصفحة RTL (يمين ➜ يسار)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        /// ✅ AppBar: الشريط العلوي
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(26, 141, 153, 1), // لون أساسي
          elevation: 0, // بدون ظل
          centerTitle: true, // العنوان في المنتصف
          iconTheme: const IconThemeData(color: Colors.white), // لون زر الرجوع
          title: const Text(
            'الأحكام والشروط',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // لون العنوان
            ),
          ),
        ),

        /// ✅ Body: محتوى الصفحة
        body: Padding(
          padding: const EdgeInsets.all(20), // مسافة داخلية حول المحتوى
          child: SingleChildScrollView(
            /// ✅ SingleChildScrollView
            /// لأن الأحكام طويلة، لازم نخلي الصفحة قابلة للتمرير
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // محاذاة البداية
              children: [
                /// ✅ قسم 1: قبول الشروط
                _sectionTitle('١. قبول الشروط'),
                _sectionText(
                  'باستخدامك لتطبيق "أجرلي"، فإنك توافق على الالتزام بهذه الأحكام والشروط. '
                  'إذا كنت لا توافق، يُرجى عدم استخدام التطبيق.',
                ),
                const SizedBox(height: 16), // مسافة بين الأقسام
                /// ✅ قسم 2: طبيعة الخدمة
                _sectionTitle('٢. طبيعة الخدمة'),
                _sectionText(
                  'التطبيق منصة تربط المستأجرين بمالكي/وكلاء العقارات لتسهيل عرض العقارات والتواصل. '
                  'التطبيق لا يعتبر طرفًا في أي عقد إيجار أو اتفاق مالي يتم خارج التطبيق.',
                ),
                const SizedBox(height: 16),

                /// ✅ قسم 3: مسؤولية المحتوى
                _sectionTitle('٣. مسؤولية المحتوى'),
                _sectionText(
                  'المالك/الوكيل مسؤول عن صحة معلومات العقار والصور والخدمات والأسعار التي ينشرها. '
                  'المستأجر مسؤول عن استخدام المعلومات بطريقة قانونية ومحترمة.',
                ),
                const SizedBox(height: 16),

                /// ✅ قسم 4: التواصل وطلبات الزيارة
                _sectionTitle('٤. التواصل وطلبات الزيارة'),
                _sectionText(
                  'طلبات التواصل/الزيارة هي وسيلة تنظيمية داخل التطبيق فقط. '
                  'لا نضمن إتمام الزيارة أو الاتفاق النهائي، ويعود ذلك لتفاهم الطرفين.',
                ),
                const SizedBox(height: 16),

                /// ✅ قسم 5: الحسابات والأمان
                _sectionTitle('٥. الحسابات والأمان'),
                _sectionText(
                  'يجب الحفاظ على سرية معلومات تسجيل الدخول. أنت مسؤول عن أي نشاط يتم عبر حسابك. '
                  'يُمنع إنشاء حسابات وهمية أو إساءة الاستخدام.',
                ),
                const SizedBox(height: 16),

                /// ✅ قسم 6: السلوكيات الممنوعة
                _sectionTitle('٦. السلوكيات الممنوعة'),
                _sectionText(
                  'يُمنع نشر محتوى غير قانوني أو مضلل، أو صور غير مناسبة، أو الإزعاج/التهديد/الاحتيال. '
                  'يحق لنا تعليق أو إغلاق الحسابات المخالفة.',
                ),
                const SizedBox(height: 16),

                /// ✅ قسم 7: التعديلات على الشروط
                _sectionTitle('٧. التعديلات على الشروط'),
                _sectionText(
                  'نحتفظ بحق تعديل هذه الشروط في أي وقت. سيتم إخطارك بالتغييرات المهمة داخل التطبيق، '
                  'واستمرارك في الاستخدام يُعتبر موافقة على التحديثات.',
                ),
                const SizedBox(height: 30),

                /// ✅ تاريخ آخر تحديث
                Center(
                  child: Text(
                    'آخر تحديث: 27 ديسمبر 2025',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ _sectionTitle
  /// دالة تساعدنا على كتابة عنوان كل قسم بنفس التنسيق (لون + خط عريض)
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(26, 141, 153, 1),
      ),
    );
  }

  /// ✅ _sectionText
  /// دالة لعرض نص القسم:
  /// - Padding بسيط من الأعلى
  /// - حجم خط 16
  /// - تباعد أسطر 1.7 لتكون القراءة أسهل
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Colors.black87,
        ),
      ),
    );
  }
}
